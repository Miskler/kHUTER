extends AndroidPluginClient

signal increment_success
signal increment_failure
signal load_success
signal load_failure
signal reveal_success
signal reveal_failure
signal unlock_success
signal unlock_failure

func _ready() -> void:
	if android_plugin:
		android_plugin.connect("incrementAchievementSuccess", Callable(self, "on_increment_success"))
		android_plugin.connect("incrementAchievementSuccessFailure", Callable(self, "on_increment_failure"))
		android_plugin.connect("loadAchievementsSuccess", Callable(self, "on_load_success"))
		android_plugin.connect("loadAchievementsFailure", Callable(self, "on_load_failure"))
		android_plugin.connect("revealAchievement", Callable(self, "on_reveal_success"))
		android_plugin.connect("revealAchievement", Callable(self, "on_reveal_failure"))
		android_plugin.connect("unlockAchievementSuccess", Callable(self, "on_unlock_success"))
		android_plugin.connect("unlockAchievementFailure", Callable(self, "on_unlock_failure"))

func on_increment_success(is_unlocked: bool) -> void:
	emit_signal("increment_success", is_unlocked)

func on_increment_failure() -> void:
	emit_signal("increment_failure")

func on_load_success(achievements: String) -> void:
	var test_json_conv = JSON.new()
	test_json_conv.parse(achievements).result as Array)
	emit_signal("load_success", test_json_conv.get_data()

func on_load_failure() -> void:
	emit_signal("load_failure")

func on_reveal_success() -> void:
	emit_signal("reveal_success")

func on_reveal_failure() -> void:
	emit_signal("reveal_failure")

func on_unlock_success() -> void:
	emit_signal("unlock_success")

func on_unlock_failure() -> void:
	emit_signal("unlock_failure")

func increment(achievement_id: String, amount: int) -> void:
	if android_plugin:
		android_plugin.incrementAchievement(achievement_id, amount)

func load_achievements(force_reload: bool) -> void:
	if android_plugin:
		android_plugin.loadAchievements(force_reload)

func reveal(achievement_id: String) -> void:
	if android_plugin:
		android_plugin.revealAchievement(achievement_id)

func show_achievements() -> void:
	if android_plugin:
		android_plugin.showAchievements()

func unlock(achievement_id) -> void:
	if android_plugin:
		android_plugin.unlockAchievement(achievement_id)
