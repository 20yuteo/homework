require 'sinatra'
require 'sinatra/reloader'
require 'mysql2'
require 'mysql2-cs-bind'
require 'sinatra/cookies'
require 'rack/flash'

db = Mysql2::Client.new(
  host: 'localhost',
  username: 'root',
  password: '',
  database: 'homework'
)

enable :sessions

get '/login' do
  @msg = session[:msg]
  session[:msg] = nil
  @msg2 = session[:msg2]
  session[:msg2] = nil
  erb :login
end

post '/login' do
  name = params[:l_name]
  password = params[:l_password]
  session[:msg] = "てめぇだれだぁ？？<br>アカウント作りやがれ。。。"
  session[:msg2] = "アカウント作る"
  res = db.xquery('select * from users where name = ? && password = ?;', name, password).to_a.first

  if res
    session[:user_id] = res['id']
    session[:user_name] = res['name']
     redirect '/home'
  else
    session[:user_id] = nil
    session[:user_name] = nil

    redirect '/login'
  end
end

get '/create' do
    @alert = session[:alert]
    session[:alert] = nil
  erb :create
end

post '/create' do
  name = params[:name]
  password = params[:password]
  session[:alert] = "他のにせぇ！！"
  res = db.xquery('select name, password from users where name = ?;', name).to_a.first
  puts res
  unless res
    db.xquery('insert into users values(null, ?, ?);', name, password)
    session[:user_name] = name
    res = db.xquery('select id from users where users.name = ?;', name).first
    session[:user_id] = res['id']
    redirect '/home'
  else

  redirect '/create'
end
end


get '/form' do
  erb :form
end

get '/home' do

  erb :home
end


get '/post' do
  @error = session[:error]
  session[:error] = nil
  erb :post
end

post '/post' do

  title = params[:title]
  post = params[:post]
  user_id = session[:user_id]
  session[:error] = "おい、何か書けよ"

  if title != '' && post != ''
    post = db.xquery('insert into posts value(null, ?, ?, ?);', title, post, user_id)
    session[:error] = nil
    redirect '/home'
  else
    redirect '/post'
  end
end

get '/show_post' do
  @show_post = db.xquery('select users.id creater_id, posts.user_id, posts.id, posts.title, posts.post from posts join users on posts.user_id = users.id;').to_a
  erb :show_post
end

post '/show_post' do

end

get '/delete/:id' do
  db.xquery('delete from posts where posts.id = ?;', session[:id])

  redirect 'show_post'
end

get '/show_user' do
  @show_user = db.xquery('select id, name from users')
  erb :show_user
end

get '/users_page/:users_id' do
  @users_id = db.xquery('select p.id, p.title, p.post, p.user_id, u.name from posts p left outer join users u on u.id = p.user_id where p.user_id = ?;', params['users_id'])
  erb :users_post
end

get '/mypage' do
  @post = db.xquery('select posts.title, posts.post from posts where user_id = ?;', session[:user_id]).to_a
  puts @post
  erb :mypage
end
