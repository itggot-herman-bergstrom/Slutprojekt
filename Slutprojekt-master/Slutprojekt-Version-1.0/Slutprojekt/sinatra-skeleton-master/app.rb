
class App < Sinatra::Base
  enable :sessions

  before do
     @user = User.get(session[:user_id])
   end

  get '/' do
    if session[:user_id]
        redirect '/home'
    else
      redirect '/login'
      end
  end

  get '/create' do

    @categories = Category.all(user_id: session[:user_id])
    erb :create
  end

  post '/create/assignment' do
    if session[:user_id]
      day = Day.first(:date => Date.parse(params['date']))

      assignment = Assignment.create(name: params['name'],
                      description: params['description'],
                      time: params['time'],
                      category_id: params['category'],
                      day: day)


    assignment.users << @user
    assignment.save

    p assignment


  end
    redirect back
  end



  post '/create/category' do
   @category = Category.create(name: params['category_name'],
                                user_id: session[:user_id])
    redirect back
  end

  get '/share/:assignment_id' do
    @assignment = Assignment.first(:id => params[:assignment_id])
    @categories = Category.all(user_id: session[:user_id])
    erb :share
  end

  post '/share/share/' do

    @assignment = Assignment.first(:id => params[:assignment_id])
    @user = User.first(email: params['email'])
    p @assignment
    p @user

    AssignmentUser.create(:assignment_id => @assignment_id, :user_id => @user_id)
    redirect back

  end


  post '/create/dag, typ' do
    day = Day.create(date: Date.new(params['date']))
    day.assignments << params[:date]
    day.save
  end

  get '/home' do

    if session[:user_id] && @user
        day = Day.first(:date => Date.today)
        @assignments = Assignment.all(day: day, :id => session[:user_id])
        @categories = Category.all(user_id: session[:user_id])
        @day = Day.first(:id => params[:day_id])

        

        erb :overview
    else
      redirect '/'
      end
  end



  get '/category/:category_id' do
    if session[:user_id] && @user
      @assignments =
      @category = Category.first(:id => params[:category_id])
      @categories = Category.all(user_id: session[:user_id])

    erb :category

    end
  end




  get '/login' do
    erb :login, layout: false
  end


  post '/user/login' do
    user = User.first(email: params['email'])
    if user && user.password == params['password']
      session[:user_id] = user.id
      redirect '/home'
    else
      redirect back
    end
    end


  post '/user/register' do
    if params['password'] == params['confirm_password']
      user = User.create(f_name: params['f_name'],
                  l_name: params['l_name'],
                         email: params['email'],
                         password: params['password']
                          )
      redirect '/home'
    end
      redirect back
  end

  get '/user/logout' do
    session[:user_id] = nil
    redirect '/'
  end

end