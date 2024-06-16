extends GutTest

const MAX_CAPACITY: int = 20
var history: CRHistory


func before_each():
	history = CRHistory.new()
	history.max_size = MAX_CAPACITY


func test_get_null_values_when_empty():
	assert_eq(history.get_item(-1), null)
	assert_eq(history.get_item(0), null)
	assert_eq(history.get_item(1), null)
	assert_eq(history.is_empty(), true)
	assert_eq(history.size(), 0)
	assert_eq(history.newest_position, history.NULL_POSITION)
	assert_eq(history.oldest_position, history.NULL_POSITION)
	assert_eq(history.has_tag("abc"), false)


func test_push_and_get_items():
	history._push(CRMemento.new({1: 1}))
	history._push(CRMemento.new({2: 2}))
	history._push(CRMemento.new({3: 3}))
	history._push(CRMemento.new({4: 4}))
	assert_eq(history.is_empty(), false)
	assert_eq(history.size(), 4)
	assert_eq(history.newest_position, 3)
	assert_eq(history.oldest_position, 0)
	assert_eq(history.get_item(-1), null)
	assert_eq(history.get_item(0).data, {1: 1})
	assert_eq(history.get_item(1).data, {2: 2})
	assert_eq(history.get_item(2).data, {3: 3})
	assert_eq(history.get_item(3).data, {4: 4})
	assert_eq(history.get_item(4), null)


func test_tag_methods():
	history.add_tag("before_1", -1)
	history.add_tag("before_2", 0)
	history._push(CRMemento.new({1: 1}))
	history._push(CRMemento.new({2: 2}))
	history._push(CRMemento.new({3: 3}))
	history._push(CRMemento.new({4: 4}))
	history.add_tag("a", 0)
	history.add_tag("ab", 1)
	history.add_tag("abb", 1)
	history.add_tag("abc", 2)
	history.add_tag("abcd", 2)
	history.add_tag("abcd", 3)
	history.add_tag("removed", 3)
	history.remove_tag("removed")
	history.add_tag("out_1", -1)
	history.add_tag("out_2", 4)
	assert_eq(history.has_tag("a"), true)
	assert_eq(history.get_tag_position("a"), 0)
	assert_eq(history.has_tag("ab"), true)
	assert_eq(history.get_tag_position("ab"), 1)
	assert_eq(history.has_tag("abb"), true)
	assert_eq(history.get_tag_position("abb"), 1)
	assert_eq(history.has_tag("abc"), true)
	assert_eq(history.get_tag_position("abc"), 2)
	assert_eq(history.has_tag("abcd"), true)
	assert_eq(history.get_tag_position("abcd"), 3)
	assert_eq(history.has_tag("removed"), false)
	assert_eq(history.get_tag_position("removed"), history.NULL_POSITION)
	assert_eq(history.has_tag("not_added"), false)
	assert_eq(history.get_tag_position("not_added"), history.NULL_POSITION)
	assert_eq(history.has_tag("before_1"), false)
	assert_eq(history.get_tag_position("before_1"), history.NULL_POSITION)
	assert_eq(history.has_tag("before_2"), false)
	assert_eq(history.get_tag_position("before_2"), history.NULL_POSITION)
	assert_eq(history.has_tag("out_1"), false)
	assert_eq(history.get_tag_position("out_1"), history.NULL_POSITION)
	assert_eq(history.has_tag("out_2"), false)
	assert_eq(history.get_tag_position("out_2"), history.NULL_POSITION)
	assert_eq(history.get_tags_at(-1), [])
	assert_eq(history.get_tags_at(0), ["a"])
	assert_eq(history.get_tags_at(1), ["ab", "abb"])
	assert_eq(history.get_tags_at(2), ["abc"])
	assert_eq(history.get_tags_at(3), ["abcd"])
	assert_eq(history.get_tags_at(4), [])


func test_push_items_in_weird_places():
	history._push(CRMemento.new({1: 1}))
	history._push(CRMemento.new({2: 2}))
	history._push(CRMemento.new({3: 3}))
	history._push(CRMemento.new({4: 4}), 2)
	assert_eq(history.get_item(-1), null)
	assert_eq(history.get_item(0).data, {1: 1})
	assert_eq(history.get_item(1).data, {2: 2})
	assert_eq(history.get_item(2).data, {4: 4})
	assert_eq(history.get_item(3), null)

	history._push(CRMemento.new({5: 5}), 1)
	assert_eq(history.get_item(-1), null)
	assert_eq(history.get_item(0).data, {1: 1})
	assert_eq(history.get_item(1).data, {5: 5})
	assert_eq(history.get_item(2), null)

	history._push(CRMemento.new({6: 6}), 0)
	assert_eq(history.get_item(-1), null)
	assert_eq(history.get_item(0).data, {6: 6})
	assert_eq(history.get_item(1), null)

	history._push(CRMemento.new({7: 7}), -1)
	assert_eq(history.get_item(-1), null)
	assert_eq(history.get_item(0).data, {6: 6})
	assert_eq(history.get_item(1).data, {7: 7})
	assert_eq(history.get_item(2), null)

	history._push(CRMemento.new({8: 8}), -2)
	assert_eq(history.get_item(-1), null)
	assert_eq(history.get_item(0).data, {6: 6})
	assert_eq(history.get_item(1).data, {7: 7})
	assert_eq(history.get_item(2), null)

	history._push(CRMemento.new({9: 9}), 100)
	assert_eq(history.get_item(-1), null)
	assert_eq(history.get_item(0).data, {6: 6})
	assert_eq(history.get_item(1).data, {7: 7})
	assert_eq(history.get_item(2), null)


func test_push_items_beyond_max_capacity():
	for i in range(20):
		history._push(CRMemento.new({i: i}))
		history.add_tag(str(i), i)
	assert_eq(history.get_item(0).data, {0: 0})
	assert_eq(history.get_item(19).data, {19: 19})
	assert_eq(history.get_tags_at(0), ["0"])
	assert_eq(history.get_tags_at(10), ["10"])

	history._push(CRMemento.new({20: 20}))
	assert_eq(history.get_item(0).data, {1: 1})
	assert_eq(history.get_item(19).data, {20: 20})
	assert_eq(history.get_tags_at(0), ["1"])
	assert_eq(history.get_tags_at(10), ["11"])

	history._push(CRMemento.new({21: 21}))
	assert_eq(history.get_item(0).data, {2: 2})
	assert_eq(history.get_item(19).data, {21: 21})
	assert_eq(history.get_tags_at(0), ["2"])
	assert_eq(history.get_tags_at(10), ["12"])

	history._push(CRMemento.new({22: 22}))
	assert_eq(history.get_item(0).data, {3: 3})
	assert_eq(history.get_item(19).data, {22: 22})
	assert_eq(history.get_tags_at(0), ["3"])
	assert_eq(history.get_tags_at(10), ["13"])

	history._push(CRMemento.new({23: 23}))
	assert_eq(history.get_item(0).data, {4: 4})
	assert_eq(history.get_item(19).data, {23: 23})
	assert_eq(history.get_tags_at(0), ["4"])
	assert_eq(history.get_tags_at(10), ["14"])


func test_clear():
	history._push(CRMemento.new({1: 1}))
	history._push(CRMemento.new({2: 2}))
	history._push(CRMemento.new({3: 3}))
	history.add_tag("a", 1)
	history.add_tag("b", 2)
	history.add_tag("c", 3)
	history.clear()
	assert_eq(history.is_empty(), true)
	assert_eq(history.size(), 0)
	assert_eq(history.get_item(0), null)
	assert_eq(history.get_item(1), null)
	assert_eq(history.get_item(2), null)
	assert_eq(history.get_tag_position("a"), history.NULL_POSITION)
	assert_eq(history.get_tag_position("b"), history.NULL_POSITION)
	assert_eq(history.get_tag_position("c"), history.NULL_POSITION)


func test_change_max_size():
	history.max_size = 2
	history._push(CRMemento.new({1: 1}))
	history._push(CRMemento.new({2: 2}))
	history.max_size = 4
	history._push(CRMemento.new({3: 3}))
	history._push(CRMemento.new({4: 4}))
	assert_eq(history.get_item(0).data, {1: 1})
	assert_eq(history.get_item(1).data, {2: 2})
	assert_eq(history.get_item(2).data, {3: 3})
	assert_eq(history.get_item(3).data, {4: 4})

	history.clear()
	history.max_size = 2
	history._push(CRMemento.new({1: 1}))
	history._push(CRMemento.new({2: 2}))
	history._push(CRMemento.new({3: 3}))
	history._push(CRMemento.new({4: 4}))
	assert_eq(history.get_item(0).data, {3: 3})
	assert_eq(history.get_item(1).data, {4: 4})
	assert_eq(history.get_item(2), null)
