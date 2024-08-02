class_name Detectable
extends Area2D

## A node that can be used to trigger behavior when the a [Lamp] area
## triggers collision. Typically this will be used to show or hide a
## scene when it passes in/out of the Lamp's range for various light
## levels.
##
## If no connections are made to [signal Detectable.detected] the default
## behavior will be to call [code]get_parent().show()[/code] on area enter
## and [code]get_parent().hide()[/code] on area exit.
##
## Because we control callision checking from the light logic for calling
## this lives in Lamp/Beam/Area signal handlers.

## detected is emitted when the Detectable node enters or exits an [Area2D] with
## the
signal detected(is_detected: bool)


func set_detected(is_detected: bool) -> void:
	if detected.get_connections().size() > 0:
		detected.emit(is_detected)
	else:
		# print('default set_detected(' + str(is_detected) + ')')
		if is_detected:
			get_parent().show()
		else:
			get_parent().hide()
