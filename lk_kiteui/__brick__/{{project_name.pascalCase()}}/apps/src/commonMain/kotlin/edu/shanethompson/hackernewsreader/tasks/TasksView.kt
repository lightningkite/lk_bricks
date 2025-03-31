package edu.shanethompson.hackernewsreader.tasks

import com.lightningkite.kiteui.Routable
import com.lightningkite.kiteui.models.Align
import com.lightningkite.kiteui.models.Icon
import com.lightningkite.kiteui.models.dp
import com.lightningkite.kiteui.models.rem
import com.lightningkite.kiteui.navigation.Page
import com.lightningkite.kiteui.reactive.Action
import com.lightningkite.kiteui.views.ViewModifiable
import com.lightningkite.kiteui.views.ViewWriter
import com.lightningkite.kiteui.views.centered
import com.lightningkite.kiteui.views.closePopovers
import com.lightningkite.kiteui.views.direct.align
import com.lightningkite.kiteui.views.direct.button
import com.lightningkite.kiteui.views.direct.col
import com.lightningkite.kiteui.views.direct.frame
import com.lightningkite.kiteui.views.direct.h2
import com.lightningkite.kiteui.views.direct.h4
import com.lightningkite.kiteui.views.direct.icon
import com.lightningkite.kiteui.views.direct.openBottomSheet
import com.lightningkite.kiteui.views.direct.recyclerView
import com.lightningkite.kiteui.views.direct.row
import com.lightningkite.kiteui.views.direct.sizeConstraints
import com.lightningkite.kiteui.views.direct.switch
import com.lightningkite.kiteui.views.direct.text
import com.lightningkite.kiteui.views.direct.textInput
import com.lightningkite.kiteui.views.expanding
import com.lightningkite.readable.reactive
import edu.shanethompson.hackernewsreader.ButtonSemantic
import edu.shanethompson.hackernewsreader.tasksVM
import kotlinx.coroutines.launch

@Routable("")
class TasksView : Page {

    override fun ViewWriter.render(): ViewModifiable {
        val tasks = tasksVM.tasks
        return frame {
            col {
                h2 { content = "Tasks" }
                reactive {
                    val reactiveTasks = tasksVM.tasks()
                    print("REACTIVE TASKS: $reactiveTasks")
                }
                expanding - recyclerView {
                    ::exists { tasks().isNotEmpty() }
                    children(tasks, render = { task ->
                        row {
                            expanding - button {
                                text {
                                    ::content { task.invoke().task.title + " Created: ${task.invoke().createdString}" }
                                }
                                action = Action(title = "Edit Task", icon = Icon.person, action = {
                                    openBottomSheet {
                                        col {
                                            h2 { ::content { "Edit: ${task().task.title}"}}
                                            spacing = 2.rem

                                            val titleInput = textInput {
                                                hint = "Title"
                                            }

                                            val descriptionInput = textInput {
                                                hint = "Description"
                                            }

                                            ButtonSemantic.onNext - button {
                                                action = Action(title = "Update Task", icon = Icon.add, action = {
    //                                                tasksVM.editTask("ID", titleInput.content.value, descriptionInput.content.value)
                                                    closePopovers()
                                                })
                                                centered - text {
                                                    content = "Confirm"
                                                }
                                            }
                                        }

                                    }
                                })
                            }
                            centered - sizeConstraints(minWidth = 16.dp, minHeight = 16.dp) - switch {
                                checked.value = task.state.raw.task.completed
                                checked.addListener {
                                    launch {
                                        tasksVM.toggleComplete(task.state.raw.task.id)
                                    }
                                }
                            }
                        }
                    })
                }
            }

            centered - h4 {
                ::exists { tasks().isEmpty() }
                content = "No Tasks"
            }

            align(Align.End, Align.End) - ButtonSemantic.onNext - button {
                action = Action(title = "Add Task", icon = Icon.add, action = {
                    openBottomSheet {
                        col {
                            h2("Add Task")
                            spacing = 2.rem

                            val titleInput = textInput {
                                hint = "Title"
                            }
                            val descriptionInput = textInput {
                                hint = "Description"
                            }

                            ButtonSemantic.onNext - button {
                                action = Action(title = "Confirm New Task", icon = Icon.add, action = {
                                    tasksVM.addTask(titleInput.content.value, descriptionInput.content.value)
                                    closePopovers()
                                })
                                centered - text {
                                    content = "Confirm"
                                }
                            }
                        }
                    }
                })
                icon {
                    val icon = Icon.add
                    source = icon
                }
            }
        }
    }
}

