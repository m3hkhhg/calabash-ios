require 'json'
require 'calabash-cucumber/utils/logging'

module Calabash
  module Cucumber

    # Device encapsulates information about the device or simulator that the
    # app is running on.  It also includes the following information about the
    # app that is running on the current device.
    #
    # * The version of the embedded Calabash server.
    # * Whether or not the app is an iPhone-only app that is being emulated on
    #   an iPad.
    class Device

      include Calabash::Cucumber::Logging

      # @!visibility private
      GESTALT_IPHONE = 'iPhone'

      # @!visibility private
      GESTALT_IPAD = 'iPad'

      # @!visibility private
      GESTALT_IPHONE5 = '4-inch'

      # @!visibility private
      GESTALT_SIM_SYS = 'x86_64'

      # @!visibility private
      GESTALT_IPOD = 'iPod'

      # @!attribute [r] endpoint
      # The http address of this device.
      # @example
      #  http://192.168.0.2:37265
      # @return [String] an ip address with port number.
      attr_reader :endpoint

      # The device family of this device.
      #
      # @note Also know as the form factor.
      #
      # @example
      #  # will be one of
      #  iPhone
      #  iPod
      #  iPad
      #
      # @!attribute [r] device_family
      # @return [String] the device family
      attr_reader :device_family

      # @!visibility private
      # @attribute [r] simulator_details
      # @return [String] Additional details about the simulator.  If this device
      #  is a physical device, returns nil.
      attr_reader :simulator_details

      # The `major.minor.[.patch]` version of iOS that is running on this device.
      #
      # @example
      #  7.1
      #  6.1.2
      #  5.1.1
      #
      # @attribute [r] ios_version
      # @return [String] the version of the iOS that is running on this device
      attr_reader :ios_version

      # The hardware architecture of this device.  Also known as the chip set.
      #
      # @example
      #  # simulator
      #  i386
      #  x86_64
      #
      # @example
      #  # examples from physical devices
      #  armv6
      #  armv7s
      #  arm64
      #
      # @attribute [r] system
      # @return [String] the hardware architecture of this device.
      #  this device.
      attr_reader :system

      # The version of the embedded Calabash server that is running in the
      # app under test on this device.
      #
      # @example
      #  0.9.168
      #  0.10.0.pre1
      #
      # @attribute [r] server_version
      # @return [String] the major.minor.patch[.pre\d] version of the embedded
      #  Calabash server
      attr_reader :server_version

      # Indicates whether or not the app under test on this device is an
      #  iPhone-only app that is being emulated on an iPad.
      #
      # @note If the `1x` or `2x` button is visible, then the app is being
      #  emulated.
      #
      # @attribute [r] iphone_app_emulated_on_ipad
      # @return [Boolean] `true` if the app under test is emulated
      attr_reader :iphone_app_emulated_on_ipad

      # The form factor of this device.
      # @attribute [r] form_factor
      #
      # Will be one of:
      #   * ipad
      #   * iphone 4in
      #   * iphone 3.5in
      #   * iphone 6
      #   * iphone 6+
      #   * "" # if no information can be found.
      attr_reader :form_factor

      # For Calabash server version > 0.10.2 provides
      # device specific screen information.
      #
      # This is a hash of form:
      #  {
      #    :sample => 1,
      #    :height => 1334,
      #    :width => 750,
      #    :scale" => 2
      #  }
      #
      #
      # @attribute [r] screen_dimensions
      # @return [Hash] screen dimensions, scale and down/up sampling fraction.
      attr_reader :screen_dimensions

      # @deprecated 0.13.1 no replacement
      # Indicates whether or not this device has a 4in screen.
      # @attribute [r] iphone_4in
      # @return [Boolean] `true` if this device has a 4in screen.
      attr_reader :iphone_4in

      # @deprecated 0.10.0 no replacement
      # @!attribute [rw] udid
      # @return [String] The udid of this device.
      attr_accessor :udid

      # Creates a new instance of Device.
      #
      # @see Calabash::Cucumber::Core#server_version
      #
      # @param [String] endpoint the http address of this device
      # @param [Hash] version_data the output of the `server_version` function
      # @return [Device] a new Device instance
      def initialize (endpoint, version_data)
        simulator_device = version_data['simulator_device']
        @endpoint = endpoint
        @system = version_data['system']
        @device_family = @system.eql?(GESTALT_SIM_SYS) ? simulator_device : @system.split(/[\d,.]/).first
        @simulator_details = version_data['simulator']
        @ios_version = version_data['iOS_version']
        @server_version = version_data['version']
        @iphone_app_emulated_on_ipad = version_data['iphone_app_emulated_on_ipad']
        screen_dimensions = version_data['screen_dimensions']
        if screen_dimensions
          @screen_dimensions = {}
          screen_dimensions.each_pair do |key,val|
            @screen_dimensions[key.to_sym] = val
          end
        end
        @form_factor = version_data['form_factor']

        # Deprecated 0.13.0
        @iphone_4in = version_data['4inch']
      end

      # Is this device a simulator or physical device?
      # @return [Boolean] true if this device is a simulator
      def simulator?
        system.eql?(GESTALT_SIM_SYS)
      end

      # Is this device a device or simulator?
      # @return [Boolean] true if this device is a physical device
      def device?
        not simulator?
      end

      # Is this device an iPhone?
      # @return [Boolean] true if this device is an iphone
      def iphone?
        device_family.eql? GESTALT_IPHONE
      end

      # Is this device an iPod?
      # @return [Boolean] true if this device is an ipod
      def ipod?
        device_family.eql? GESTALT_IPOD
      end

      # Is this device an iPad?
      # @return [Boolean] true if this device is an ipad
      def ipad?
        device_family.eql? GESTALT_IPAD
      end

      # Is this device a 4in iPhone?
      # @return [Boolean] true if this device is a 4in iphone
      def iphone_4in?
        form_factor == 'iphone 4in'
      end

      # Is this device an iPhone 6?
      # @return [Boolean] true if this device is an iPhone 6
      def iphone_6?
        form_factor == 'iphone 6'
      end

      # Is this device an iPhone 6+?
      # @return [Boolean] true if this device is an iPhone 6+
      def iphone_6_plus?
        form_factor == 'iphone 6+'
      end

      # Is this device an iPhone 3.5in?
      # @return [Boolean] true if this device is an iPhone 3.5in?
      def iphone_35in?
        form_factor == 'iphone 3.5in'
      end

      # @!visibility private
      def version_hash (version_str)
        tokens = version_str.split(/[,.]/)
        {:major_version => tokens[0],
         :minor_version => tokens[1],
         :bug_version => tokens[2]}
      end

      # The major iOS version of this device.
      # @return [String] the major version of the OS
      def ios_major_version
        version_hash(ios_version)[:major_version]
      end

      # Is this device running iOS 8?
      # @return [Boolean] true if the major version of the OS is 8
      def ios8?
        ios_major_version.eql?('8')
      end

      # Is this device running iOS 7?
      # @return [Boolean] true if the major version of the OS is 7
      def ios7?
        ios_major_version.eql?('7')
      end

      # Is this device running iOS 6?
      # @return [Boolean] true if the major version of the OS is 6
      def ios6?
        ios_major_version.eql?('6')
      end

      # Is this device running iOS 5?
      # @return [Boolean] true if the major version of the OS is 5
      def ios5?
        ios_major_version.eql?('5')
      end

      # @deprecated 0.11.2 Replaced with screen_dimensions.
      #
      # The screen size of the device.
      #
      # @return [Hash] representation of the screen size
      def screen_size
        _deprecated('0.11.2', 'Replaced with screen_dimensions', :warn)
        return screen_dimensions if screen_dimensions
        return { :width => 768, :height => 1024 } if ipad?
        return { :width => 320, :height => 568 } if iphone_4in?
        { :width => 320, :height => 480 }
      end

      # Is the app that is running an iPhone-only app emulated on an iPad?
      #
      # @note If the app is running in emulation mode, there will be a 1x or 2x
      #   scale button visible on the iPad.
      #
      # @return [Boolean] true if the app running on this devices is an
      #   iPhone-only app emulated on an iPad
      def iphone_app_emulated_on_ipad?
        iphone_app_emulated_on_ipad
      end

      # The version of the embedded Calabash server running in the app under
      # test on this device.
      # @deprecated 0.9.169 replaced with `server_version`
      # @see #server_version
      # @return [String] the version of the embedded Calabash server
      def framework_version
        _deprecated('0.9.169', "use 'server_version', instead", :warn)
        @server_version
      end

      # @deprecated 0.10.0 no replacement
      def udid
        _deprecated('0.10.0', 'no replacement', :warn)
        @udid
      end

      # @deprecated 0.10.0 no replacement
      def udid=(value)
        _deprecated('0.10.0', 'no replacement', :warn)
        @udid = value
      end

      # @deprecated 0.9.168 replaced with iphone_4in?
      # @see #iphone_4in?
      # Is this device an iPhone 5?
      # @note Deprecated because the iPhone 5S reports as an iPhone6,*.
      # @return [Boolean] true if this device is an iPhone 5
      def iphone_5?
        _deprecated('0.9.168', "use 'iphone_4in?' instead", :warn)
        iphone_4in?
      end

      # @deprecated 0.13.1 - Call `iphone_4in?` instead.
      # @see #iphone_4in?
      # @note Deprecated after introducing new `form_factor` behavior.
      # @return [Boolean] true if this device is an iPhone 5 or 5s
      def iphone_4in
        _deprecated('0.13.1', "use 'iphone_4in?' instead", :warn)
        @iphone_4in
      end
    end
  end
end
