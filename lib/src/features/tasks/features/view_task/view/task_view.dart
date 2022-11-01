import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigaturnip/src/features/app/app.dart';
import 'package:gigaturnip/src/features/tasks/features/view_task/bloc/task_bloc.dart';
import 'package:gigaturnip/src/widgets/richtext/richtext_view.dart';
import 'package:go_router/go_router.dart';
import 'package:uniturnip/json_schema_ui.dart';

class TaskView extends StatefulWidget {
  const TaskView({Key? key}) : super(key: key);

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  late TaskBloc taskBloc;
  late UIModel formController;
  late String richText;
  bool isRichTextViewed = true;

  @override
  void initState() {
    taskBloc = context.read<TaskBloc>();
    taskBloc.add(InitializeTaskEvent());
    formController = UIModel(
      data: taskBloc.state.responses ?? {},
      disabled: taskBloc.state.complete,
      onUpdate: ({required MapPath path, required Map<String, dynamic> data}) {
        taskBloc.add(UpdateTaskEvent(data));
        final dynamicJsonMetadata = taskBloc.state.stage.dynamicJsons;
        if (dynamicJsonMetadata.isNotEmpty) {
          if (dynamicJsonMetadata.first['main'] == path.last) {
            taskBloc.add(GetDynamicSchemaTaskEvent(data));
          }
        }
      },
      saveFile: (rawFile, path, type, {private = false}) {
        return context.read<TaskBloc>().uploadFile(
              file: rawFile,
              path: path,
              type: type,
              private: private,
            );
      },
      getFile: (path) {
        return context.read<TaskBloc>().getFile(path);
      },
      saveAudioRecord: (file, private) async {
        final task = await context.read<TaskBloc>().uploadFile(
              file: file,
              type: FileType.any,
              private: private,
              path: null,
            );
        return task!.snapshot.ref.fullPath;
      },
    );
    richText = taskBloc.state.stage.richText ?? '';
    if (isRichTextViewed && richText.isNotEmpty) {
      _showRichText();
    }
    super.initState();
  }

  @override
  void dispose() {
    taskBloc.add(ExitTaskEvent());
    super.dispose();
  }

  void _showRichText() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RichTextView(htmlText: richText),
        ),
      );
      setState(() {
        isRichTextViewed = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    var location = Router.of(context).routeInformationProvider?.value.location;
    var queryStartIndex = location?.indexOf('?') ?? -1;
    String query;
    if (queryStartIndex > 0) {
      query = location?.substring(queryStartIndex) ?? '';
    } else {
      query = '';
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(context.read<TaskBloc>().state.name,
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            maxLines: 5,
            style: Theme.of(context).textTheme.headlineMedium),
        leading: BackButton(
          onPressed: () {
            context.read<AppBloc>().add(const AppSelectedTaskChanged(null));
            context.read<TaskBloc>().add(ExitTaskEvent());
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showRichText();
            },
            icon: const Icon(Icons.info),
          )
        ],
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          formController.data = state.responses ?? {};
          formController.disabled = state.complete;
          if (state.taskStatus == TaskStatus.redirectToNextTask) {
            if (state.nextTask != null) {
              context.read<AppBloc>().add(AppSelectedTaskChanged(state.nextTask));
              final selectedCampaign = context.read<AppBloc>().state.selectedCampaign!;
              context.go('/campaign/${selectedCampaign.id}/tasks/${state.nextTask!.id}$query');
            }
          } else if (state.taskStatus == TaskStatus.redirectToTasksList) {
            context.pop();
          }
          // TODO: implement error handling
        },
        buildWhen: (previousState, currentState) {
          var hasPreviousTasksChange = previousState.previousTasks != currentState.previousTasks;
          var hasCompleteChange = previousState.complete != currentState.complete;
          var hasSchemaChange =
              !(const DeepCollectionEquality().equals(previousState.schema, currentState.schema));

          var shouldRebuild = hasPreviousTasksChange || hasCompleteChange || hasSchemaChange;
          return shouldRebuild;
        },
        builder: (context, state) {
          return ListView(
            children: [
              if (state.previousTasks.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      for (var task in state.previousTasks)
                        JSONSchemaUI(
                          schema: task.schema!,
                          ui: task.uiSchema!,
                          formController: UIModel(disabled: true, data: task.responses ?? {}),
                          hideSubmitButton: true,
                        ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: JSONSchemaUI(
                  schema: state.schema!,
                  ui: state.uiSchema!,
                  formController: formController,
                  onSubmit: ({required Map<String, dynamic> data}) {
                    taskBloc.add(SubmitTaskEvent(data));
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
