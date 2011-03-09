module ChiliprojectTravelReport
  module Patches
    module IssuePatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable

          # Issues where a trip's depart or return dates are within date_from or date_to
          # Partial trips are included, e.g. leave before date_to but return afterwards
          #
          named_scope :traveling_between, lambda {|date_from, date_to|
            if date_from.blank? || date_to.blank?
              nil_conditions
            else
              depart_custom_field_id = Setting.plugin_chiliproject_travel_report['depart_custom_field_id']
              return_custom_field_id = Setting.plugin_chiliproject_travel_report['return_custom_field_id']
              return nil_conditions unless depart_custom_field_id.present? && return_custom_field_id.present?

              db_table = CustomValue.table_name
              conditions = ARCondition.new
              
              if depart_custom_field_id && return_custom_field_id
                conditions.add([
                                "
#{Issue.table_name}.id IN (
  SELECT #{Issue.table_name}.id
    FROM #{Issue.table_name}
    LEFT OUTER JOIN #{db_table}
      ON #{db_table}.customized_type='Issue'
      AND #{db_table}.customized_id=#{Issue.table_name}.id
      AND #{db_table}.custom_field_id=#{depart_custom_field_id}
    WHERE
      #{db_table}.value >= :date_from
      AND #{db_table}.value <= :date_to
  UNION
  SELECT #{Issue.table_name}.id
    FROM #{Issue.table_name}
    LEFT OUTER JOIN #{db_table}
      ON #{db_table}.customized_type='Issue'
      AND #{db_table}.customized_id=#{Issue.table_name}.id
      AND #{db_table}.custom_field_id=#{return_custom_field_id}
    WHERE
      #{db_table}.value >= :date_from
      AND #{db_table}.value <= :date_to
)",
                                {
                                  :date_from => date_from,
                                  :date_to => date_to
                                }])

                {:conditions => conditions.conditions }

              else
                nil_conditions
              end

              
            end
            
          }
        end
      end

      module ClassMethods
        # Returns a conditions that prevents any record from being returned
        def nil_conditions
          { :conditions => '0 = 1' }
        end
        
      end

      module InstanceMethods
      end
    end
  end
end
