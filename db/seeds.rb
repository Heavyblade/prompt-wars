TimeOffType.find_or_create_by!(name: "Vacation")
TimeOffType.find_or_create_by!(name: "Sick")
TimeOffType.find_or_create_by!(name: "Personal")

admin = User.find_or_initialize_by(email: "admin@example.com")
admin.first_name = "A"
admin.last_name = "Admin"
admin.role = :admin
admin.password = "password"
admin.save!

manager = User.find_or_initialize_by(email: "manager@example.com")
manager.first_name = "M"
manager.last_name = "Manager"
manager.role = :manager
manager.password = "password"
manager.save!

dept = Department.find_or_create_by!(name: "Engineering", manager: manager)

employee = User.find_or_initialize_by(email: "employee@example.com")
employee.first_name = "E"
employee.last_name = "Employee"
employee.role = :employee
employee.password = "password"
employee.department = dept
employee.manager = manager
employee.save!

puts "Seeded: #{TimeOffType.count} time_off_types, Users: #{User.count}, Departments: #{Department.count}"
