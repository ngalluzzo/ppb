class_name WorldLifecycleAdapter
extends RefCounted

func add_to_parent(parent: Node, child: Node) -> void:
	if parent == null or child == null:
		return
	parent.add_child(child)

func free_node(node: Node) -> void:
	if node == null:
		return
	if node.is_inside_tree():
		node.queue_free()
	else:
		node.free()
