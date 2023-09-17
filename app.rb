# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/content_for'
require 'tilt/erubis'
require 'pry'
require_relative 'database_persistence'

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
  set :erb, escape_html: true
  also_reload 'database_persistence.rb'
end

before do
  @storage = DatabasePersistence.new(logger)
end

def load_expense(id)
  @storage.find_expense(id)
end

get '/expenses' do
  redirect '/'
end

get '/' do
  @expenses = @storage.all_expenses
  @total = @storage.total_amount
  erb :home
end

get '/expenses/delete_all_expenses' do
  @storage.delete_all_expenses
  session[:success] = 'All expenses have been deleted.'
  redirect '/'
end

get '/expenses/:id/edit' do
  @id = params[:id].to_i
  @expense = load_expense(@id)
  erb :edit_expense
end

get '/expenses/:id/delete' do
  @id = params[:id].to_i
  @storage.delete_expense(@id)
  session[:success] = 'The expense has been deleted.'
  redirect '/'
end

get '/expenses/add' do
  erb :add_expense
end

post '/expenses/add' do
  info = []
  info << params[:name]
  info << params[:amount]
  info << params[:category]
  info << params[:date]
  @storage.add_expense(info)

  session[:success] = 'The expense has been added.'
  redirect '/'
end

post '/expenses/:id' do
  id = params[:id].to_i
  info = []
  info << params[:name]
  info << params[:amount]
  info << params[:category]

  @storage.update_expense(id, info)
  session[:success] = 'The expense has been updated.'
  redirect '/'
end
