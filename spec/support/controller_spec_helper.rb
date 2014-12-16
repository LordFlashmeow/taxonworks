require_relative 'config/initialization_constants' 

# Helpers for controller specs (typically those automatically generated).
# 
# These methods should be used within a before(:each) block.
module ControllerSpecHelper

  def sign_in_user_and_select_project(user, project_id)
    @request.session = {project_id: project_id}
    remember_token = User.secure_random_token
    cookies.permanent[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.encrypt(remember_token)) 
    set_user_project(user.id,project_id)
  end

  # Signs in user 1 and project 1.
  def sign_in
    @request.session = {project_id: 1}
    remember_token = User.secure_random_token
    cookies.permanent[:remember_token] = remember_token
    User.find(1).update_attribute(:remember_token, User.encrypt(remember_token)) 
    set_user_project(1,1)
  end

  def sign_in_administrator
    @request.session = {project_id: 1}
    remember_token = User.secure_random_token
    cookies.permanent[:remember_token] = remember_token

    pwd = 'abcD123!'
    user = User.create(name: 'Administrator (controller tests)', is_administrator: true, email: 'admin_foo@bar.com', password: pwd, password_confirmation: pwd, self_created: true)
    user.update_attribute(:remember_token, User.encrypt(remember_token))

    set_user_project(user.id, 1)
  end

  def sign_in_project_administrator
    @request.session = {project_id: 1}
    remember_token = User.secure_random_token
    cookies.permanent[:remember_token] = remember_token

    pwd = 'abcD123!'
    user = User.create(name: 'Administrator (controller tests)', is_project_administrator: true, email: 'foo@bar.com', password: pwd, password_confirmation: pwd, self_created: true)
    user.update_attribute(:remember_token, User.encrypt(remember_token)) 

    set_user_project(user.id, 1)
  end

  # We do this to handle the pre-request stubbing of objects in controllers. 
  # It mocks the behaviour of having accessed at least one page post login. 
  def set_user_project(user_id, project_id)
    $user_id ||= user_id
    $project_id ||= project_id
  end

  # Sign in user 1, but do not set project
  def sign_in_user
    remember_token = User.secure_random_token
    cookies.permanent[:remember_token] = remember_token
    User.find(1).update_attribute(:remember_token, User.encrypt(remember_token)) 
  end

end


