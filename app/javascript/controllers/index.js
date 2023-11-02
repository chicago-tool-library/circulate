import { Application } from "stimulus"

window.Stimulus = Application.start()

import AlertController from './alert_controller'
Stimulus.register('alert', AlertController)

import AppointmentDateController from './appointment_date_controller'
Stimulus.register('appointment-date', AppointmentDateController)

import AppointmentsIndexController from './appointments_index_controller'
Stimulus.register('appointments-indes', AppointmentsIndexController)

import AutocompleteController from './autocomplete_controller'
Stimulus.register('autocomplete', AutocompleteController)

import CollapseController from './collapse_controller'
Stimulus.register('collapse', CollapseController)

import ConditionalFieldController from './conditional_field_controller'
Stimulus.register('conditional-field', ConditionalFieldController)

import EmailSettingsEditorController from './email_settings_editor_controller'
Stimulus.register('email-settings-editor', EmailSettingsEditorController)

import FindToolController from './find_tool_controller'
Stimulus.register('find-tool', FindToolController)

import HoldOrderController from './hold_order_controller'
Stimulus.register('hold-order', HoldOrderController)

import ImageEditorController from './image_editor_controller'
Stimulus.register('image-editor', ImageEditorController)

import ItemFilterController from './item_filter_controller'
Stimulus.register('item-filter', ItemFilterController)

import ModalController from './modal_controller'
Stimulus.register('modal', ModalController)

import MultiSelectController from './multi_select_controller'
Stimulus.register('multi-select', MultiSelectController)

import NotesController from './notes_controller'
Stimulus.register('notes', NotesController)

import PortalController from './portal_controller'
Stimulus.register('portal', PortalController)

import RequestItemController from './request_item_controller'
Stimulus.register('request-item', RequestItemController)

import SidebarController from './sidebar_controller'
Stimulus.register('sidebar', SidebarController)

import TagEditorController from './tag_editor_controller'
Stimulus.register('tag-editor', TagEditorController)

import ToggleController from './toggle_controller'
Stimulus.register('toggle', ToggleController)

import TreeNavController from './tree_nav_controller'
Stimulus.register('tree-nav', TreeNavController)
