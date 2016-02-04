class ApiController < ApplicationController
  before_action -> { :authorize_resource_owner! },         only: :resource
  before_action -> { :authorize_resource_owner! :public }, only: :resource_with_scope
  before_action -> { :authorize_client_app! },             only: :client
  before_action -> { :authorize_client_app! :public },     only: :client_with_scope

  def client
  end

  def client_with_scope
  end

  def resource
  end

  def resource_with_scope
  end

  def signin
  end

  def public
  end
end
