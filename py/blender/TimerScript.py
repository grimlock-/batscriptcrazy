#This script is used to create a timer when making a video in the Blender VSE.
#When executed, the script grabs every marker on the timeline and groups them
#in pairs by name. Markers should be named in the pattern <sectionname>.Start
#and <sectionname>.End and there can be no more than two markers per section.
#Every section should have an associated text strip with the naming pattern
#<sectionname>.Timer
#WARNING: Each *.Start marker should be created before it's associated *.End
#marker. Otherwise they will appear to the script in reverse order and the
#timer for that section will not work.
import bpy

scene = bpy.data.scenes['Scene']
marks = []
st = -1
nm = ''

for marker in scene.timeline_markers:
    i = marker.name.find('Start')
    if i != -1:
        st = marker.frame
        nm = marker.name
    else:
        i = marker.name.find('End')
        if i != -1:
            nm = marker.name[:i]
            marks.append((nm, st, marker.frame))
            st = 0
            nm = ''
        else:
            print('Unknown label: ' + marker.name)

for i in marks:
    print(i)

def frame_step(scene):
    for item in marks:
        if scene.frame_current >= item[1] and scene.frame_current < item[2]:
            obj = scene.sequence_editor.sequences_all[item[0] + 'Timer']
            fps = scene.render.fps / scene.render.fps_base  # actual framerate
            cur_frame = scene.frame_current - item[1]
            obj.text = '{0:.3f}'.format(cur_frame/fps)
            break

bpy.app.handlers.frame_change_pre.append(frame_step)
bpy.app.handlers.render_pre.append(frame_step)