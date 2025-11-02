extends Node2D

var entry_scene = preload("res://UI/entry.tscn")

@export var leaderboard_internal_name: String = ""
@export var include_archived: bool

@onready var leaderboard_name: Label = %LeaderboardName
@onready var entries_container: VBoxContainer = %Entries
@onready var info_label: Label = %InfoLabel
@onready var username: TextEdit = %Username
@onready var submit = %Submit

var _entries_error: bool

func _ready() -> void:
	leaderboard_name.text = leaderboard_name.text.replace("{leaderboard}", leaderboard_internal_name)
	await _load_entries()
	_set_entry_count()

func _set_entry_count():
	if entries_container.get_child_count() == 0:
		info_label.text = "No entries yet!" if not _entries_error else "Failed loading leaderboard %s. Does it exist?" % leaderboard_internal_name
	else:
		info_label.text = "%s entries" % entries_container.get_child_count()

func _create_entry(entry: TaloLeaderboardEntry) -> void:
	var entry_instance = entry_scene.instantiate()
	entry_instance.set_data(entry)
	entries_container.add_child(entry_instance)

func _build_entries() -> void:
	for child in entries_container.get_children():
		child.queue_free()

	var entries = Talo.leaderboards.get_cached_entries(leaderboard_internal_name)

	for entry in entries:
		entry.position = entries.find(entry)
		_create_entry(entry)

func _load_entries() -> void:
	var page := 0
	var done := false

	while !done:
		var options := Talo.leaderboards.GetEntriesOptions.new()
		options.page = page
		options.include_archived = include_archived

		var res := await Talo.leaderboards.get_entries(leaderboard_internal_name, options)

		if not is_instance_valid(res):
			_entries_error = true
			return

		var entries := res.entries
		var is_last_page := res.is_last_page

		if is_last_page:
			done = true
		else:
			page += 1

	_build_entries()

func _on_submit_pressed() -> void:
	toggle_submit_button(false)
	
	if !is_username_input_valid():
		info_label.text = "Invalid Name!"
		toggle_submit_button(true)
		return
	
	await Talo.players.identify("username", username.text)
	var score := Global.total_score

	var res := await Talo.leaderboards.add_entry(leaderboard_internal_name, score)
	assert(is_instance_valid(res))
	info_label.text = "You scored %s points!%s" % [score, " Your highscore was updated!" if res.updated else ""]

	_build_entries()
	toggle_submit_button(true)
	username.clear()

func toggle_submit_button(active: bool):
	if active:
		submit.disabled = false
		submit.text = "Submit Score"
	else:
		submit.disabled = true
		submit.text = "Processing..."

func is_username_input_valid() -> bool:
	if username.text == "":
		return false
	else:
		return true
	# TODO: add filter to only block NSFW names
