class Holdings
  class Status
    ##
    # Representing libraries that are in process
    class InProcess
      LIBRARIES = ['HV-ARCHIVE'].freeze

      def initialize(callnumber)
        @callnumber = callnumber
      end

      def in_process?
        library_in_process?
      end

      private

      def library_in_process?
        LIBRARIES.include?(@callnumber.library)
      end
    end
  end
end
