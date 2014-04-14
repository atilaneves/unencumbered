module CucumberDMappings
  def features_dir
    "features"
  end

  def write_passing_mapping(step_name)
    @code ||= <<-EOF
import std.stdio;
void main() {
    writeln("1 scenario (1 passed)");
}
EOF
  end

  def run_feature
    write_file('foo.d', @code);
    in_current_dir do
        expect( File.exist? 'foo.d' ).to be_true
        compile
      end
    run('/tmp/foo')
  end

  def assert_passing_scenario
    assert_partial_output("1 scenario (1 passed)", all_output)
#    assert_success true
  end

  def write_failing_mapping(step_name)
    pending "Not implemented yet"
  end

  def assert_failing_scenario
    pending "Not implemented yet"
  end

  def write_pending_mapping(step_name)
    pending "Not implemented yet"
  end

  def assert_pending_scenario
    pending "Not implemented yet"
  end

  def assert_undefined_scenario
    pending "Not implemented yet"
  end

  def failed_output
    pending "Not implemented yet"
  end

  def assert_no_partial_output(msg, all_output)
    pending "Not implemented yet"
  end

  def write_calculator_code
    pending "Not implemented yet"
  end

  def write_mappings_for_calculator
    @code += <<-EOF
void given() {
}
EOF
  end

  def write_custom_world_constructor
    pending "Not implemented yet"
  end

  def write_world_function
    pending "Not implemented yet"
  end

  def write_mapping_calling_world_function(step_name)
    pending "Not implemented yet"
  end

  def write_world_variable_with_numeric_value(step_name)
    pending "Not implemented yet"
  end

  def assert_suggested_step_definition_snippet(stepdef_keyword, stepdef_pattern, parameter_count = 0,
                                               doc_string = false, data_table = false)
    pending "Not implemented yet"
  end

  def write_scenario(options = {})
    pending "Not implemented yet"
  end

  def write_mapping_receiving_data_table_as_raw(step_name)
    pending "Not implemented yet"
  end

  def write_mapping_receiving_data_table_as_hashes(step_name)
    pending "Not implemented yet"
  end

  def write_mapping_receiving_data_table_as_headless_row_array(step_name)
    pending "Not implemented yet"
  end

  def run_feature_with_tags(*tag_groups)
    write_file('foo.d', @code);
  end

  def assert_executed_scenarios(*scenario_offsets)
    pending "Not implemented yet"
  end

  def write_passing_hook(options = {})
    pending "Not implemented yet"
  end

  def assert_data_table_equals_json(step_name)
    pending "Not implemented yet"
  end

  def write_failing_mapping_with_message(step_name, message)
    pending "Not implemented yet"
  end

  def assert_scenario_reported_as_failing(step_name)
    pending "Not implemented yet"
  end

  def assert_scenario_not_reported_as_failing(step_name)
    pending "Not implemented yet"
  end

  def write_mapping_incrementing_world_variable_by_value(step_name, increment_value)
    pending "Not implemented yet"
  end

  def write_mapping_logging_world_variable_value(step_name, time = "1")
    pending "Not implemented yet"
  end

  def assert_world_function_called
    pending "Not implemented yet"
  end

  private

  def compile()
    compiler_output = %x[ dmd foo.d -of/tmp/foo 2>&1 ]
    expect($?.success?).to be_true, "Compilation failed! Output:\n#{compiler_output}"
  end
end

World(CucumberDMappings)
