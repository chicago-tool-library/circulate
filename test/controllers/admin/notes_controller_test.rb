require "test_helper"

class Admin::NotesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionView::RecordIdentifier

  setup do
    @member_1 = create(:member, full_name: "Member 1")
    @admin_user = create(:admin_user, member: @member_1)
    sign_in @admin_user
    @user = create(:user, member: @member_2)
  end

  test "creates a note for a member" do
    post admin_member_notes_path(@member_1), params: {note: {body: "hello"}}, as: :turbo_stream

    assert_equal 1, @member_1.reload.notes.length
    assert_turbo_stream action: "replace", target: "new-note"
    assert_turbo_stream action: "append", target: "notes"
  end

  test "updates a note for a member" do
    note = create(:note, notable: @member_1)

    patch admin_member_note_path(@member_1, @member_1.notes[0]),
      params: { note: { body: "updated" } },
      headers: { "Accept" => "text/html" }

    assert_response :see_other
    assert_redirected_to admin_member_url(@member_1, anchor: dom_id(note))
    assert_equal 1, @member_1.reload.notes.length
  end

  test "deletes a note for a member" do
    create(:note, notable: @member_1)

    delete "/admin/members/#{@member_1.id}/notes/#{@member_1.notes[0].id}", as: :turbo_stream

    assert_response :ok
    assert_equal 0, @member_1.reload.notes.length
  end
end
