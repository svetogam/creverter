extends Node

var a := "initial"
var b := "initial"
var c := "initial"


func save_dictionary() -> Dictionary:
	return {
		"a": a,
		"b": b,
		"c": c,
	}


func load_dictionary(memento: Dictionary) -> void:
	a = memento.a
	b = memento.b
	c = memento.c


func save_memento() -> Dictionary:
	return {
		"a": a,
		"b": b,
		"c": c,
	}


func load_memento(memento: Dictionary) -> void:
	a = memento.a
	b = memento.b
	c = memento.c


func save_array() -> Array:
	return [a, b, c]


func load_array(array: Array) -> void:
	a = array[0]
	b = array[1]
	c = array[2]
