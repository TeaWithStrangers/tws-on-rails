class ShowAttendeePhoneNumberForUser
    def initialize(current_user, attendance)
        @current_user = current_user
        @attendance = attendance
    end

    def call
        # logic operating on @current_user and @attendance
        # returns true/false
        @current_user.host? &&
            @attendance.todo? &&
            !@attendance.occurred? &&
            @attendance.provide_phone_number &&
            !@attendance.tea_time.cancelled?
    end
end
