module Flagging
    private

    def flag_obj(obj)
        obj.flagged = true
        obj.save
    end

    def unflag_obj(obj)
        obj.flagged = false
        obj.save
    end
end