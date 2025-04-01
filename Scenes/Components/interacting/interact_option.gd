class_name InteractOption
extends Control

enum { LAYOUT_LEFT, LAYOUT_RIGHT }

@export var expandable := false
@export var label: String:
	get:
		return _clabel
	set(value):
		_clabel = value
		if _llabel:
			_llabel.text = _clabel
		if _rlabel:
			_rlabel.text = _clabel
@export var layout := LAYOUT_RIGHT
@export var symbol: Image = null

var _clabel: String = ""

# TODO: This should be abstracted out at some point but its not really worth the effort...
@onready var _left: Control = $Left
@onready var _lchevron: TextureRect = $Left/Chevron
@onready var _llabel: Label = $Left/Label
@onready var _lpanel: Panel = $Left/Panel
@onready var _lselection: TextureRect = $Left/Selection
@onready var _right: Control = $Right
@onready var _rchevron: TextureRect = $Right/Chevron
@onready var _rlabel: Label = $Right/Label
@onready var _rpanel: Panel = $Right/Panel
@onready var _rselection: TextureRect = $Right/Selection
@onready var _symbol: TextureRect = $SymbolContainer/Symbol

## Public


func blur() -> void:
	if symbol:
		_symbol.get_parent().hide()
	match layout:
		LAYOUT_LEFT:
			_lselection.hide()
		LAYOUT_RIGHT:
			_rselection.hide()


func focus() -> void:
	if symbol:
		_symbol.get_parent().show()
	match layout:
		LAYOUT_LEFT:
			_lselection.show()
		LAYOUT_RIGHT:
			_rselection.show()


func toggle_chevron() -> void:
	match layout:
		LAYOUT_LEFT:
			_lchevron.flip_v = !_lchevron.flip_v
		LAYOUT_RIGHT:
			_rchevron.flip_v = !_rchevron.flip_v


## Override


func _ready() -> void:
	_symbol.texture = ImageTexture.create_from_image(symbol)
	_symbol.get_parent().hide()
	match layout:
		LAYOUT_LEFT:
			_right.hide()
			_lselection.hide()
			_llabel.text = _clabel

			if expandable:
				_lchevron.show()
			else:
				_lchevron.hide()
		LAYOUT_RIGHT:
			_left.hide()
			_rselection.hide()
			_rlabel.text = _clabel

			if expandable:
				_rchevron.show()
			else:
				_rchevron.hide()
