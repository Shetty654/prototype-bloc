import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/project/project_bloc.dart';

class Project extends StatefulWidget {
  const Project({super.key});

  @override
  State<Project> createState() => _ProjectState();
}

class _ProjectState extends State<Project> {
  @override
  void initState() {
    BlocProvider.of<ProjectBloc>(context).add(ProjectListRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select a Project')),
      body: BlocBuilder<ProjectBloc, ProjectState>(
        builder: (context, state) {
          if (state is ProjectListLoadInProgress) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProjectListLoadSuccess) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: state.projects.length,
                    itemBuilder: (context, index) {
                      final project = state.projects[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          child: ListTile(
                            title: Text(project),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, '/home', arguments: {'projectName': project});
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is ProjectListLoadFailure) {
            return const Center(child: Text("Failed to load projects"));
          } else {
            return const SizedBox(); // Or a placeholder
          }
        },
      ),
    );
  }
}
