class Quote < ApplicationRecord
  belongs_to :company
  
  validates :name, presence: true

  scope :ordered, -> { order(id: :desc) }
  #after_create_commit -> { broadcast_prepend_to "quotes", partial: "quotes/quote", locals: { quote: self }, target: "quotes" }
  #after_create_commit -> { broadcast_prepend_to "quotes", partial: "quotes/quote", locals: { quote: self } }
  
  # this is fully functional:
  #after_create_commit -> { broadcast_prepend_to "quotes" }
  #after_update_commit -> { broadcast_replace_to "quotes" }
  #after_destroy_commit -> { broadcast_remove_to "quotes" }

  # It is possible to improve the performance of this code 
  # by making the broadcasting part asynchronous using background jobs
  #after_create_commit -> { broadcast_prepend_later_to "quotes" }
  #after_update_commit -> { broadcast_replace_later_to "quotes" }
  #after_destroy_commit -> { broadcast_remove_to "quotes" }

  # there is some syntactic sugar to avoid writing those three callbacks all the time. 
  # Let's replace them with an equivalent and shorter version in our Quote model:
  broadcasts_to ->(quote) { "quotes" }, inserts_by: :prepend
end