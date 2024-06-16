extends GutTest

const Agent := preload("agent.gd")
const AgentNode := preload("agent_node.gd")


func test_call_without_connections():
	var reverter := CReverter.new()
	watch_signals(reverter)
	assert_eq(reverter.cursor, CRHistory.NULL_POSITION)
	assert_eq(reverter.is_undo_possible(), false)
	assert_eq(reverter.is_redo_possible(), false)

	reverter.undo()
	assert_eq(reverter.cursor, CRHistory.NULL_POSITION)

	reverter.redo()
	assert_eq(reverter.cursor, CRHistory.NULL_POSITION)

	reverter.revert()
	assert_eq(reverter.cursor, CRHistory.NULL_POSITION)

	reverter.load_oldest()
	assert_eq(reverter.cursor, CRHistory.NULL_POSITION)

	reverter.load_newest()
	assert_eq(reverter.cursor, CRHistory.NULL_POSITION)

	assert_signal_emit_count(reverter, "saved", 0)
	assert_signal_emit_count(reverter, "loaded", 0)


func test_call_without_commits():
	var reverter := CReverter.new()
	watch_signals(reverter)
	var agent := Agent.new()
	reverter.connect_save_load(
			agent.get_instance_id(), agent.save_dictionary, agent.load_dictionary)
	assert_eq(reverter.cursor, CRHistory.NULL_POSITION)
	assert_eq(reverter.is_undo_possible(), false)
	assert_eq(reverter.is_redo_possible(), false)

	reverter.undo()
	assert_eq(reverter.cursor, CRHistory.NULL_POSITION)

	reverter.redo()
	assert_eq(reverter.cursor, CRHistory.NULL_POSITION)

	reverter.revert()
	assert_eq(reverter.cursor, CRHistory.NULL_POSITION)

	reverter.load_oldest()
	assert_eq(reverter.cursor, CRHistory.NULL_POSITION)

	reverter.load_newest()
	assert_eq(reverter.cursor, CRHistory.NULL_POSITION)

	reverter.load_tag("not_saved")
	assert_eq(reverter.cursor, CRHistory.NULL_POSITION)
	assert_signal_emit_count(reverter, "saved", 0)
	assert_signal_emit_count(reverter, "loaded", 0)


func test_save_load_with_one_commit():
	var reverter := CReverter.new()
	watch_signals(reverter)
	var agent := Agent.new()
	reverter.connect_save_load(
			agent.get_instance_id(), agent.save_dictionary, agent.load_dictionary)
	agent.a = "1"
	reverter.commit()
	assert_eq(reverter.cursor, 0)
	assert_eq(reverter.is_undo_possible(), false)
	assert_eq(reverter.is_redo_possible(), false)
	assert_signal_emit_count(reverter, "saved", 1)
	assert_signal_emit_count(reverter, "loaded", 0)

	agent.a = "0"
	reverter.undo()
	assert_eq(agent.a, "0")
	assert_eq(reverter.cursor, 0)
	assert_eq(reverter.is_undo_possible(), false)
	assert_eq(reverter.is_redo_possible(), false)
	assert_signal_emit_count(reverter, "saved", 1)
	assert_signal_emit_count(reverter, "loaded", 0)

	agent.a = "0"
	reverter.redo()
	assert_eq(agent.a, "0")
	assert_eq(reverter.cursor, 0)
	assert_eq(reverter.is_undo_possible(), false)
	assert_eq(reverter.is_redo_possible(), false)
	assert_signal_emit_count(reverter, "saved", 1)
	assert_signal_emit_count(reverter, "loaded", 0)

	agent.a = "0"
	reverter.revert()
	assert_eq(agent.a, "1")
	assert_eq(reverter.cursor, 0)
	assert_eq(reverter.is_undo_possible(), false)
	assert_eq(reverter.is_redo_possible(), false)
	assert_signal_emit_count(reverter, "saved", 1)
	assert_signal_emit_count(reverter, "loaded", 1)

	agent.a = "0"
	reverter.load_oldest()
	assert_eq(agent.a, "1")
	assert_eq(reverter.cursor, 0)
	assert_eq(reverter.is_undo_possible(), false)
	assert_eq(reverter.is_redo_possible(), false)
	assert_signal_emit_count(reverter, "saved", 1)
	assert_signal_emit_count(reverter, "loaded", 2)

	agent.a = "0"
	reverter.load_newest()
	assert_eq(agent.a, "1")
	assert_eq(reverter.cursor, 0)
	assert_eq(reverter.is_undo_possible(), false)
	assert_eq(reverter.is_redo_possible(), false)
	assert_signal_emit_count(reverter, "saved", 1)
	assert_signal_emit_count(reverter, "loaded", 3)


func test_save_load_with_multiple_commits():
	var reverter := CReverter.new()
	watch_signals(reverter)
	var agent := Agent.new()
	reverter.connect_save_load(
			agent.get_instance_id(), agent.save_dictionary, agent.load_dictionary)
	agent.a = "1"
	reverter.commit()
	agent.a = "2"
	reverter.commit()
	agent.a = "3"
	reverter.commit()
	assert_eq(agent.a, "3")
	assert_eq(reverter.cursor, 2)
	assert_eq(reverter.is_undo_possible(), true)
	assert_eq(reverter.is_redo_possible(), false)
	assert_signal_emit_count(reverter, "saved", 3)
	assert_signal_emit_count(reverter, "loaded", 0)

	agent.a = "0"
	reverter.undo()
	assert_eq(agent.a, "2")
	assert_eq(reverter.cursor, 1)
	assert_eq(reverter.is_undo_possible(), true)
	assert_eq(reverter.is_redo_possible(), true)
	assert_signal_emit_count(reverter, "saved", 3)
	assert_signal_emit_count(reverter, "loaded", 1)

	agent.a = "0"
	reverter.undo()
	assert_eq(agent.a, "1")
	assert_eq(reverter.cursor, 0)
	assert_eq(reverter.is_undo_possible(), false)
	assert_eq(reverter.is_redo_possible(), true)
	assert_signal_emit_count(reverter, "saved", 3)
	assert_signal_emit_count(reverter, "loaded", 2)

	agent.a = "0"
	reverter.undo()
	assert_eq(agent.a, "0")
	assert_eq(reverter.cursor, 0)
	assert_eq(reverter.is_undo_possible(), false)
	assert_eq(reverter.is_redo_possible(), true)
	assert_signal_emit_count(reverter, "saved", 3)
	assert_signal_emit_count(reverter, "loaded", 2)

	agent.a = "0"
	reverter.redo()
	assert_eq(agent.a, "2")
	assert_eq(reverter.cursor, 1)
	assert_eq(reverter.is_undo_possible(), true)
	assert_eq(reverter.is_redo_possible(), true)
	assert_signal_emit_count(reverter, "saved", 3)
	assert_signal_emit_count(reverter, "loaded", 3)

	agent.a = "0"
	reverter.redo()
	assert_eq(agent.a, "3")
	assert_eq(reverter.cursor, 2)
	assert_eq(reverter.is_undo_possible(), true)
	assert_eq(reverter.is_redo_possible(), false)
	assert_signal_emit_count(reverter, "saved", 3)
	assert_signal_emit_count(reverter, "loaded", 4)

	agent.a = "0"
	reverter.redo()
	assert_eq(agent.a, "0")
	assert_eq(reverter.cursor, 2)
	assert_eq(reverter.is_undo_possible(), true)
	assert_eq(reverter.is_redo_possible(), false)
	assert_signal_emit_count(reverter, "saved", 3)
	assert_signal_emit_count(reverter, "loaded", 4)

	agent.a = "0"
	reverter.revert()
	assert_eq(agent.a, "3")
	assert_eq(reverter.cursor, 2)
	assert_eq(reverter.is_undo_possible(), true)
	assert_eq(reverter.is_redo_possible(), false)
	assert_signal_emit_count(reverter, "saved", 3)
	assert_signal_emit_count(reverter, "loaded", 5)

	agent.a = "0"
	reverter.load_oldest()
	assert_eq(agent.a, "1")
	assert_eq(reverter.cursor, 0)
	assert_eq(reverter.is_undo_possible(), false)
	assert_eq(reverter.is_redo_possible(), true)
	assert_signal_emit_count(reverter, "saved", 3)
	assert_signal_emit_count(reverter, "loaded", 6)

	agent.a = "0"
	reverter.load_newest()
	assert_eq(agent.a, "3")
	assert_eq(reverter.cursor, 2)
	assert_eq(reverter.is_undo_possible(), true)
	assert_eq(reverter.is_redo_possible(), false)
	assert_signal_emit_count(reverter, "saved", 3)
	assert_signal_emit_count(reverter, "loaded", 7)

	agent.a = "0"
	reverter.load_oldest()
	reverter.commit()
	reverter.redo()
	assert_eq(agent.a, "2")
	assert_eq(reverter.cursor, 1)
	assert_eq(reverter.is_undo_possible(), true)
	assert_eq(reverter.is_redo_possible(), true)
	assert_signal_emit_count(reverter, "saved", 3)
	assert_signal_emit_count(reverter, "loaded", 9)

	reverter.load_oldest()
	agent.a = "4"
	reverter.commit()
	reverter.redo()
	assert_eq(agent.a, "4")
	assert_eq(reverter.cursor, 1)
	assert_eq(reverter.is_undo_possible(), true)
	assert_eq(reverter.is_redo_possible(), false)
	assert_signal_emit_count(reverter, "saved", 4)
	assert_signal_emit_count(reverter, "loaded", 10)


func test_save_load_tags():
	var reverter := CReverter.new()
	watch_signals(reverter)
	var agent := Agent.new()
	reverter.connect_save_load(
			agent.get_instance_id(), agent.save_dictionary, agent.load_dictionary)
	agent.a = "1"
	reverter.commit("tag_1")
	agent.a = "2"
	reverter.commit()
	agent.a = "3"
	reverter.commit("tag_3")
	agent.a = "4"
	reverter.commit()
	reverter.load_tag("tag_1")
	assert_eq(agent.a, "1")
	assert_eq(reverter.cursor, 0)
	assert_eq(reverter.history.has_tag("tag_1"), true)
	assert_eq(reverter.history.has_tag("tag_3"), true)
	assert_signal_emit_count(reverter, "saved", 4)
	assert_signal_emit_count(reverter, "loaded", 1)

	agent.a = "0"
	reverter.load_tag("tag_3")
	assert_eq(agent.a, "3")
	assert_eq(reverter.cursor, 2)
	assert_signal_emit_count(reverter, "saved", 4)
	assert_signal_emit_count(reverter, "loaded", 2)

	agent.a = "0"
	reverter.load_tag("tag_3")
	assert_eq(agent.a, "3")
	assert_eq(reverter.cursor, 2)
	assert_signal_emit_count(reverter, "saved", 4)
	assert_signal_emit_count(reverter, "loaded", 3)

	agent.a = "0"
	reverter.undo()
	assert_eq(agent.a, "2")
	assert_eq(reverter.cursor, 1)
	assert_signal_emit_count(reverter, "saved", 4)
	assert_signal_emit_count(reverter, "loaded", 4)

	agent.a = "0"
	reverter.load_tag("invalid_tag")
	assert_eq(agent.a, "0")
	assert_eq(reverter.cursor, 1)
	assert_signal_emit_count(reverter, "saved", 4)
	assert_signal_emit_count(reverter, "loaded", 4)

	agent.a = "5"
	reverter.commit()
	reverter.load_tag("tag_3")
	assert_eq(agent.a, "5")
	assert_eq(reverter.cursor, 2)
	assert_eq(reverter.history.has_tag("tag_1"), true)
	assert_eq(reverter.history.has_tag("tag_3"), false)
	assert_signal_emit_count(reverter, "saved", 5)
	assert_signal_emit_count(reverter, "loaded", 4)


func test_save_load_with_multiple_connections():
	var reverter := CReverter.new()
	watch_signals(reverter)
	var agent_1 := Agent.new()
	var agent_2 := Agent.new()
	var agent_3 := Agent.new()
	reverter.connect_save_load(
			agent_1.get_instance_id(), agent_1.save_dictionary, agent_1.load_dictionary)
	reverter.connect_save_load(
			agent_2.get_instance_id(), agent_2.save_memento, agent_2.load_memento)
	reverter.connect_save_load(
			agent_3.get_instance_id(), agent_3.save_dictionary, agent_3.load_dictionary)
	agent_1.a = "1"
	agent_2.a = "2"
	agent_3.a = "3"
	reverter.commit()
	agent_1.a = "4"
	agent_2.a = "5"
	agent_3.a = "6"
	reverter.commit()
	agent_1.a = "7"
	agent_2.a = "8"
	agent_3.a = "9"
	reverter.commit("tag")
	reverter.undo()
	assert_eq(agent_1.a, "4")
	assert_eq(agent_2.a, "5")
	assert_eq(agent_3.a, "6")
	assert_signal_emit_count(reverter, "saved", 3)
	assert_signal_emit_count(reverter, "loaded", 1)

	reverter.undo()
	assert_eq(agent_1.a, "1")
	assert_eq(agent_2.a, "2")
	assert_eq(agent_3.a, "3")
	assert_signal_emit_count(reverter, "saved", 3)
	assert_signal_emit_count(reverter, "loaded", 2)

	reverter.load_tag("tag")
	assert_eq(agent_1.a, "7")
	assert_eq(agent_2.a, "8")
	assert_eq(agent_3.a, "9")
	assert_signal_emit_count(reverter, "saved", 3)
	assert_signal_emit_count(reverter, "loaded", 3)


func test_ignore_equal_states():
	var reverter := CReverter.new()
	watch_signals(reverter)
	var agent_1 := Agent.new()
	var agent_2 := Agent.new()
	reverter.connect_save_load(
			agent_1.get_instance_id(), agent_1.save_dictionary, agent_1.load_dictionary)
	reverter.connect_save_load(
			agent_2.get_instance_id(), agent_2.save_memento, agent_2.load_memento)
	agent_1.a = "1"
	agent_2.a = "2"
	reverter.commit()
	agent_1.a = "2"
	agent_2.a = "1"
	reverter.commit()
	agent_1.a = "2"
	agent_2.a = "1"
	reverter.commit()
	agent_1.a = "1"
	agent_2.a = "2"
	reverter.commit()
	reverter.undo()
	assert_eq(agent_1.a, "2")
	assert_eq(agent_2.a, "1")
	assert_signal_emit_count(reverter, "saved", 3)
	assert_signal_emit_count(reverter, "loaded", 1)

	reverter.undo()
	assert_eq(agent_1.a, "1")
	assert_eq(agent_2.a, "2")
	assert_signal_emit_count(reverter, "saved", 3)
	assert_signal_emit_count(reverter, "loaded", 2)


func test_ignore_invalid_connections_and_commits():
	var reverter := CReverter.new()
	watch_signals(reverter)
	var agent_1 := Agent.new()
	var agent_2 := Agent.new()
	var agent_3 := Agent.new()
	var agent_4 := Agent.new()
	var agent_5 := Agent.new()
	reverter.commit()
	reverter.connect_save_load(
			"id_1", agent_1.save_dictionary, agent_1.load_dictionary)
	reverter.connect_save_load(
			"recurring_id", agent_2.save_dictionary, agent_2.load_dictionary)
	reverter.connect_save_load(
			"id_2", agent_3.save_array, agent_3.load_array)
	reverter.connect_save_load(
			"recurring_id", agent_4.save_dictionary, agent_4.load_dictionary)
	agent_1.a = "1"
	agent_2.a = "2"
	agent_3.a = "3"
	agent_4.a = "4"
	agent_5.a = "5"
	reverter.commit()
	reverter.connect_save_load(
			"id_3", agent_5.save_dictionary, agent_5.load_dictionary)
	assert_eq(agent_1.a, "1")
	assert_eq(agent_2.a, "2")
	assert_eq(agent_3.a, "3")
	assert_eq(agent_4.a, "4")
	assert_eq(agent_5.a, "5")
	assert_signal_emit_count(reverter, "saved", 1)
	assert_signal_emit_count(reverter, "loaded", 0)

	agent_1.a = "6"
	agent_2.a = "7"
	agent_3.a = "8"
	agent_4.a = "9"
	agent_5.a = "10"
	reverter.commit()
	assert_eq(agent_1.a, "6")
	assert_eq(agent_2.a, "7")
	assert_eq(agent_3.a, "8")
	assert_eq(agent_4.a, "9")
	assert_eq(agent_5.a, "10")
	assert_signal_emit_count(reverter, "saved", 2)
	assert_signal_emit_count(reverter, "loaded", 0)

	reverter.undo()
	assert_eq(agent_1.a, "1")
	assert_eq(agent_2.a, "2")
	assert_eq(agent_3.a, "8")
	assert_eq(agent_4.a, "9")
	assert_eq(agent_5.a, "10")
	assert_signal_emit_count(reverter, "saved", 2)
	assert_signal_emit_count(reverter, "loaded", 1)


func test_ignore_tracked_objects_after_they_are_freed():
	var reverter := CReverter.new()
	watch_signals(reverter)
	var agent_1 := AgentNode.new()
	var agent_2 := AgentNode.new()
	add_child(agent_1)
	add_child(agent_2)
	reverter.connect_save_load(
			agent_1.get_instance_id(), agent_1.save_dictionary, agent_1.load_dictionary)
	reverter.connect_save_load(
			agent_2.get_instance_id(), agent_2.save_dictionary, agent_2.load_dictionary)
	agent_1.a = "1"
	agent_2.a = "4"
	reverter.commit()
	agent_1.a = "2"
	agent_2.a = "5"
	agent_2.free()
	reverter.commit()
	reverter.undo()
	assert_freed(agent_2)
	assert_eq(agent_1.a, "1")
	assert_signal_emit_count(reverter, "saved", 2)
	assert_signal_emit_count(reverter, "loaded", 1)

	reverter.redo()
	assert_freed(agent_2)
	assert_eq(agent_1.a, "2")
	assert_signal_emit_count(reverter, "saved", 2)
	assert_signal_emit_count(reverter, "loaded", 2)

	agent_1.free()
