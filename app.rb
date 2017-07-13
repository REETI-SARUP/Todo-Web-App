require 'sinatra'
require 'data_mapper'
DataMapper.setup(:default, 'sqlite:////home/rsubuntu/Desktop/coding ninjas web development/todo_app_withLogin/project.db')

class User
	include DataMapper::Resource

	property :id, Serial
	property :email, String
	property :password, String
end

class Todo
	include DataMapper::Resource

	property :id,         Serial    
  	property :task,       String    
  	property :done,       Boolean  
  	property :imp,        Boolean  
  	property :urgent,     Boolean 
  	property :user_id,    Numeric 
end

DataMapper.finalize # We are telling data mapper, that we are done, defining tables

DataMapper.auto_upgrade! 

enable :sessions


# class Todo
# 	attr_accessor :task, :done, :imp, :urgent
# 	def initialize task
# 		@task = task
# 		@done = false
# 		@imp = false
# 		@urgent = false
# 	end
# end

# tasks = []

#t1 = Todo.new "First"
#t2 = Todo.new "second"
#t3 = Todo.new "Third"

#tasks << t1
#tasks << t2
#tasks << t3


get '/' do
	if session[:user_id].nil?
		return redirect '/signin'
	end
	puts User.all.count
	tasks = Todo.all(user_id: session[:user_id])
	erb :index, locals: {user_id: session[:user_id], tasks: tasks}
end

get '/signout' do
	session[:user_id] = nil
	return redirect '/'
end

get '/signin' do
	erb :signin
end

post '/signin' do
	email = params["email"]
	password = params["Password"]
	user = User.all(email: email).first

	puts user.class

	if user.nil?
		return redirect '/signup'
	else
		if user.password == password
			session[:user_id] = user.id
			return redirect '/'
		else
			return redirect '/signin'
		end

	end
	redirect '/signin'
end

get '/signup' do
	erb :signup
end

post '/signup' do
	email = params["email"]
	password = params["Password"]

	user = User.all(email: email).first

	if user
		return redirect '/signup'
	else
		user = User.new
		user.email = email
		user.password = password
		user.save
		session[:user_id] = user.id
		return redirect '/'
	end
end

post '/add' do
  puts params
  task = params["task"]
  todo = Todo.new 
  todo.task = task
  todo.done = false
  todo.imp = params["imp"]
  todo.urgent = params["urgent"]
  todo.user_id = session[:user_id]
  todo.save
  return redirect '/'
end

post '/done' do
	task_id = params["id"].to_i
	todo = Todo.get(task_id)
	todo.done = !todo.done
	todo.save
    return redirect '/'
end

post '/check' do
	# puts params
	# user = User.all(id: session[:user_id]).first
	# task = params["task"]
	# todo = Todo.new
	# todo.task = task


	task_id = params["id"].to_i
	todo = Todo.get(task_id)
	todo.imp = params["imp"]
	todo.urgent = params["urgent"]
	todo.save
	return redirect '/'
end
	
