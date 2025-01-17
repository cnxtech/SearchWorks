class Holdings
  ##
  # A class representing a single barcoded item in an object's holdings.
  # This comes from the solr document's item_display field as serialized holdings info.
  # 0 barcode -|- 1 library -|- 2 home location -|- 3 current location -|- 4 item type -|-
  # 5 truncated call number -|- 6 shelfkey -|- 7 reverse shelfkey -|- 8 callnumber -|-
  # 9 full shelfkey -|- 10 public note -|- 11 callnumber type -|- 12 course id -|- 13 reserve desk -|- 14 loan period
  class Callnumber
    attr_writer :current_location, :status
    attr_reader :document
    attr_accessor :due_date
    def initialize(holding_info, document: nil)
      @holding_info = holding_info
      @document = document
    end

    def present?
      @holding_info.present? &&
        !(item_display[1] == 'SUL' && internet_resource?) &&
        !bound_with?
    end

    def browsable?
      shelfkey.present? &&
        reverse_shelfkey.present? &&
        Constants::BROWSABLE_CALLNUMBERS.include?(callnumber_type)
    end

    def on_order?
      barcode.blank? &&
        home_location == 'ON-ORDER' &&
        current_location.code == 'ON-ORDER'
    end

    def barcode
      item_display[0]
    end

    def library
      if current_location_is_reserve_desk?
        Constants::RESERVE_DESKS[current_location.code]
      else
        standard_or_zombie_library
      end
    end

    def home_location
      if treat_current_location_as_home_location?
        reserve_desk_or_current_location
      else
        item_display[2]
      end
    end

    def current_location
      Holdings::Location.new(item_display[3])
    end

    def type
      item_display[4]
    end

    def truncated_callnumber
      item_display[5]
    end

    def shelfkey
      item_display[6]
    end

    def reverse_shelfkey
      item_display[7]
    end

    def callnumber
      case
      when item_display[8].present?
        item_display[8]
      when internet_resource?
        'eResource'
      else
        '(no call number)'
      end
    end

    def full_shelfkey
      item_display[9]
    end

    def public_note
      item_display[10].gsub('.PUBLIC.', '').strip if item_display[10]
    end

    def callnumber_type
      item_display[11]
    end

    def course_id
      item_display[12]
    end

    def reserve_desk
      item_display[13]
    end

    def loan_period
      item_display[14]
    end

    def status
      @status ||= Holdings::Status.new(self)
    end

    def on_reserve?
      reserve_desk.present? && loan_period.present?
    end

    def treat_current_location_as_home_location?
      Constants::CURRENT_HOME_LOCS.include?(current_location.code)
    end

    delegate :requestable?, to: :request_status

    delegate :must_request?, to: :request_status

    def stackmapable?
      stackmapable_library? && stackmapable_location?
    end

    def bound_with?
      Constants::BOUND_WITH_LOCS.include?(home_location)
    end

    def live_status?
      library != 'LANE-MED'
    end

    def as_json(*)
      methods = (public_methods(false) - [:as_json, :status, :current_location, :document])
      callnumber_info = methods.each_with_object({}) do |meth, obj|
        obj[meth.to_sym] = send(meth) if method(meth).arity == 0
      end
      callnumber_info[:current_location] = current_location.as_json
      callnumber_info[:status] = status.as_json
      callnumber_info
    end

    private

    def internet_resource?
      home_location == 'INTERNET'
    end

    # supports whitelist for library
    def stackmapable_library?
      Constants::STACKMAP_LIBS.include?(library)
    end

    # supports a global blacklist and local blacklist for home_location
    def stackmapable_location?
      return false if Constants::STACKMAP_BLACKLIST[:global].include?(home_location)
      return true if Constants::STACKMAP_BLACKLIST[library].blank? # no local blacklist registered, so we're done

      !Constants::STACKMAP_BLACKLIST[library].include?(home_location)
    end

    def standard_or_zombie_library
      if item_display[1].blank? || %w(SUL PHYSICS).include?(item_display[1])
        'ZOMBIE'
      else
        item_display[1]
      end
    end

    def reserve_desk_or_current_location
      if current_location_is_reserve_desk?
        reserve_desk_home_location
      else
        current_location.code
      end
    end

    def reserve_desk_home_location
      if current_location.code == 'E-RESV'
        'SW-E-RESERVE-DESK'
      else
        'SW-RESERVE-DESK'
      end
    end

    def current_location_is_reserve_desk?
      Constants::RESERVE_DESKS.keys.include?(current_location.code)
    end

    def request_status
      @request_status ||= Holdings::Requestable.new(self)
    end

    def item_display
      @item_display ||= @holding_info.split('-|-').map(&:strip)
    end
  end
end
