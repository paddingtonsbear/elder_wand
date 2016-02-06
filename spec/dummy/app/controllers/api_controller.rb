class ApiController < ApplicationController
  before_action -> { elder_wand_authenticate_resource_owner! },     only: :signin
  before_action -> { elder_wand_authorize_resource_owner! },        only: :resource
  before_action -> { elder_wand_authorize_resource_owner! :admin }, only: :resource_with_scope
  before_action -> { elder_wand_authorize_client_app! },            only: :client
  before_action -> { elder_wand_authorize_client_app! :admin },     only: :client_with_scope

  def client
    render_json
  end

  def client_with_scope
    render_json
  end

  def resource
    render_json
  end

  def resource_with_scope
    render_json
  end

  def signin
    render_json
  end

  def public
    render_json
  end

  private

  def render_json
    render status: :ok, json: {}
  end
end
