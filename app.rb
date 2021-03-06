#encoding: utf-8
require 'rubygems'
require 'sinatra'
# require 'sinatra/reloader'
require 'sinatra/activerecord'

# rem
set :database, 'sqlite3:pizzashop.db'

class Product < ActiveRecord::Base
end

class Order < ActiveRecord::Base
  validates :cl_name, presence: true, length: { minimum: 3 } 
  validates :cl_phone, presence: true, length: { minimum: 5 }  
  validates :cl_adress, presence: true, length: { minimum: 5 }  
end

# .string .text .integer .float .decimal .datetime .timestamp .time .date .binary .boolean

get '/' do  # -----------------------------------------------------------------------
  @product = Product.all 
  erb :index
end

get '/about' do # -------------------------------------------------------------------
  erb :about
end

post '/cart_me' do  # ---------------------------------------------------------------
  # Этот обработчик корзины я сделал сам, но он не очень удачное решение, т.к. мне приходится передавать всю БД на страницу браузера, и там уже вибирать необходимые данные для отображения таблици с заказанными товарами. Т.е. нагружаем браузер у клиента и ещё сеть. Вариант обработчика ниже делает отбор записей из БД только по тем товарам, которые заказаены. И передаёт значительно меньший объём информации в браузер. Т.е. нагружаем сервер. 

  @product = Product.all          # Перенести db в переменную для страницы /cart
  # эта переменная понадобиться для создания таблицы заказанного товара с расчётом
  # стоимости всего чека и каждого товара через стоимость из db.

  @order = params[:order]
  puts @order                     ### FOR DEBUGING
  @hh = {}

  arr_position = @order.split(',')        # Расщепляет строку на массив товаров 

  arr_position.each do |item|
    
    arr_ = item.split('=')  # Расщепляет элемент на массив (имя, колич-во)

    if arr_.size != 2       # Если разменр этого массива не равен 2 (имя,кол-во)
      puts "Error"        # ... то это ошибка. так не должно быть! и ...
      # ... такой товар не подлежит дальнейшему расчёту, т.е. идём к следующему.

    else  # А если это не так, т.е. массив содержит два элемента (имя и кол-во),
      # ... то ПИШЕМ в ХЕШ данные по товару, но есть тонкости:  
      # Нужно подготовить данные для работы с БАЗОЙ ДАННЫХ. Для этого:
      # --------------------------------------------------------------------------
      # Сначала получим id - (код товара)
      #
      #   /- Получим код товара, для этого:
      #  !     /- возьмём нулевой элемент массива arr_  (это 'produkt_4')
      #  !    !      /- разделяем его на массив по знаку '_' ([produkt],[4])
      #  !    !     !          ! - забираем элемент (1) из полученного массива 
      key = arr_[0].split('_')[1]         # - (в данном случае это [4])

      # Далее, получим количество товара, находящееся на месте 1-го эл-та arr_
      value = arr_[1].to_i    # с преобразованием к типу integr

      puts "#{key} = #{value}" ### FOR DEBUGING

      @hh[key] = value    # Теперб ЗАНОСИМ данные по товару в ХЕШ.
      # ... ключём является id (см. выше) хранится в key
      # ... а значение - это количество товара, которое в переменной value
    end
  end

  puts @hh
  @product = Product.all
  erb :cart

end

post '/cart' do

  @orders_line = params[:order]   # присваиваем ХЕШу все параметры, переданные через POST 

  @items = parse_orders_input @orders_line  # преобразовываем строку в массив (id, cnt)

  if @items.length == 0         # Выводим сообщение, что корзина пустая
    return erb :cart_is_empty
  end

  @items.each do |item|         # Выводим список продуктов в корзине
    # id, cnt
    item[0] = Product.find(item[0])
  end

  erb :cart
end

def parse_orders_input orders_line  # метод преобразовывает строку @ordre_line в массив (id, cnt)
  #                                   'product_3=5,product_7=8,' => [ ['3', '5'], ['7', '8'] ]

  arr = []                      # готовим место для итогового массива

  s1 = @orders_line.split(',')  # поделить на массив (считать символом деления ',' (запятую))
  #                                   'product_3=5,product_7=8,' => ['product_3=5', 'product_7=8']
  
  s1.each do |x|                # перебираем все элементы (x) массива s1 

    s2 = x.split('=')               # поделить элемент массива на подмассив (разделитель '=')
   #                                   'product_3=5' => ['product_3', '5']  
  
    s3 = s2[0].split('_')           # нулевой элемент подмассива поделить на под-подмассив ('_')
   #                                   'product_3'  => ['product', '3']
   
    id  = s3[1]                 # id - это 1-ый элемент под-подмассива   '3'
    cnt = s2[1]                 # cnt - это 1-ый элемент подмассива      '5'

    sub_arr = [id, cnt]         # получаем ['3', '5']

    arr.push sub_arr            # затасливаем каждую пару ['id', 'cnt'] как элемент в массив arr 

  end                           # переходим к следующему элементу массива s1

  return arr              # возвращаем из метода полученный массив.       

end

post '/place_order' do

  @ooo = Order.new params[:order]

  # Записать данные в таблицу БД
  if @ooo.save                 # Здесь происходит валидация данных настройка которых
   #                              происходит при описании class Client (см. выше)

    erb :place_order

  else

    @error = @ooo.errors.full_messages.first
    erb "ОШИБКА"
  
  end 

end

get '/admin' do
  @orders_db = Order.all 
  erb :admin
end
