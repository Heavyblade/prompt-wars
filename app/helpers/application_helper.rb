module ApplicationHelper
  def basic_container
    'w-[300px] mx-auto justify-center'
  end

  def flash_color(key)
    case key
    when 'notice'
      'bg-blue-100 border-blue-500 text-blue-700'
    when 'alert'
      'bg-red-100 border-red-500 text-red-700'
    else
      'bg-gray-100 border-gray-500 text-gray-700'
    end
  end
end
