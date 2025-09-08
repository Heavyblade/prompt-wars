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

  def class_for_flash(key)
      case key.to_s
      when 'notice' then 'flex items-center p-4 mb-4 text-sm text-blue-800 rounded-lg bg-blue-50 dark:bg-gray-800 dark:text-blue-400'
      when 'alert' then 'flex items-center p-4 mb-4 text-sm text-red-800 rounded-lg bg-red-50 dark:bg-gray-800 dark:text-red-400'
      else 'flex items-center p-4 mb-4 text-sm text-gray-800 rounded-lg bg-gray-50 dark:bg-gray-800 dark:text-gray-300'
      end
  end
end
