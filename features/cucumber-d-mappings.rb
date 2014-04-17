module CucumberDMappings
  def features_dir
    "features"
  end

  def run_feature
    write_src
    source_path = get_absolute_path("../source")
    run("rdmd --force -I#{source_path} -I~/.dub/packages/unit-threaded-master /tmp/foo 2>&1")
  end

  def write_passing_mapping(step_name)
    write_step_code(step_name, "") # no code necessary to pass
  end

  def assert_passing_scenario
    assert_partial_output("1 scenario (1 passed)", all_output)
    assert_success true
  end

  def write_failing_mapping(step_name)
    write_step_code(step_name, 'throw new Exception("Fail");')
  end

  def write_failing_mapping_with_message(step_name, message)
    write_step_code(step_name, "throw new Exception(\"#{message}\");")
  end

  def assert_failing_scenario
    assert_partial_output("1 scenario (1 failed)", all_output)
    assert_success false
  end

  def write_pending_mapping(step_name)
    write_step_code(step_name, "pending();");
  end

  def assert_pending_scenario
    assert_partial_output("1 scenario (1 pending)", all_output)
    assert_success true
  end

  def assert_undefined_scenario
    assert_partial_output("1 scenario (1 undefined)", all_output)
    assert_success true
  end

  def failed_output
    "failed"
  end

  def write_calculator_code
    include_file("../tests/calculator/impl.d")
  end

  def write_mappings_for_calculator
    include_file("../tests/calculator/steps.d")
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
    pending
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

  def assert_scenario_reported_as_failing(scenario_name)
    assert_partial_output("!!! Scenario: #{scenario_name} failed", all_output)
    assert_success false
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

  def add_src(code)
    @code ||= <<-EOF
import cucumber;
import unit_threaded;
import std.stdio;
import std.conv;
import std.traits;
import std.math;
EOF
    @code += code
  end

  def write_step_code(step_name, code)
    @num_steps ||= 0
    @num_steps += 1
    add_src <<-EOF

@Match!(r\"#{step_name}\")
void testFunc_#{@num_steps}(in string[]) {
    #{code}
}

EOF
  end

  def write_src
    write_main_function
    write_file('/tmp/foo.d', @code)
    puts "/tmp/foo.d:\n#{@code}\n"
  end

  def write_main_function
        add_src <<-EOF
int main() {
    const results = runFeature!__MODULE__(#{read_steps});
    writeln(results.toString());
    return results.numFailing ? 1 : 0;
}
EOF
  end

  def compile()
    write_src
    compiler_output = %x[ dmd -Isource /tmp/foo.d 2>&1 ]
    expect($?.success?).to be_true, "Compilation failed! Output:\n#{compiler_output}\nCode:\n#{@code}\n"
  end

  def get_absolute_path(relative_path)
    File.expand_path(relative_path, File.dirname(__FILE__))
  end

  def read_steps()
    lines = File.readlines("tmp/aruba/features/a_feature.feature")
    lines.map { |l| l.chomp }.select { |l| !l.empty? }
  end

  def include_file(relative_file_path)
    absolute_file_path = get_absolute_path(relative_file_path)
    lines = File.readlines(absolute_file_path)
    lines = lines.select {|l| l !~ /^module .+;$/}
    lines = lines.select {|l| l !~ /^import tests\..+$/}
    lines.each { |l| add_src l }
  end
end

World(CucumberDMappings)
