class CreateProducts < ActiveRecord::Migration[6.0]
  def change
  	create_table :products do |t|
  		t.string :title
  		t.text :discription
  		t.decimal :price
  		t.decimal :size
  		t.boolean :is_spicy
  		t.boolean :is_veg
  		t.boolean :is_best_offer
  		t.string :path_of_image

  		t.timestamps
  	end
  	# .string .text .integer .float .decimal .datetime .timestamp .time .date .binary .boolean
  end 
end
