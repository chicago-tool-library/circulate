require "test_helper"

class Admin::NotesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include ActionView::RecordIdentifier

  setup do
    @member_1 = create(:member, full_name: "Member 1")
    @member_2 = create(:member, full_name: "Member 2")
    @admin_user = create(:admin_user, member: @member_1)
    sign_in @admin_user
    @user = create(:user, member: @member_2)
  end

  test "should create a note for a member" do
    assert_equal 0, @member_1.notes.length
    post admin_member_notes_path(@member_1), params: {note: {body: "hello"}}
    assert_equal 1, @member_1.reload.notes.length
    assert_redirected_to [:admin, @member_1, anchor: dom_id(@member_1.notes[0])]
  end

  test "should update a note for a member" do
    assert_equal 0, @member_1.notes.length
    post admin_member_notes_path(@member_1), params: {note: {body: "hello"}}
    assert_equal 1, @member_1.reload.notes.length
    patch "/admin/members/#{@member_1.id}/notes/#{@member_1.notes[0].id}", params: {note: {body: "updated"}}
    assert_equal 1, @member_1.reload.notes.length
    assert_redirected_to [:admin, @member_1, anchor: dom_id(@member_1.notes[0])]
  end

  test "should delete a note for a member" do
    assert_equal 0, @member_1.notes.length
    post admin_member_notes_path(@member_1), params: {note: {body: "hello"}}
    assert_equal 1, @member_1.reload.notes.length
    delete "/admin/members/#{@member_1.id}/notes/#{@member_1.notes[0].id}"
    assert_redirected_to [:admin, @member_1]
  end
end
