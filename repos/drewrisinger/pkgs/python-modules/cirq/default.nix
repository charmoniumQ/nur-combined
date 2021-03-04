{ stdenv
, lib
, buildPythonPackage
, pythonOlder
, fetchFromGitHub
, freezegun
# nixpkgs <= 20.09
, google_api_core ? null
# nixpkgs >= 20.09
, google-api-core ? null
, matplotlib
, networkx
, numpy
, pandas
, protobuf
, requests
, scipy
, sortedcontainers
, sympy
, typing-extensions
  # test inputs
, pytestCheckHook
, pytest-asyncio
, pytest-benchmark
, ply
, pydot
, pyyaml
, pygraphviz
}:

assert (lib.versionOlder lib.trivial.release "21.03") -> google_api_core != null && google-api-core == null;
assert (lib.versionAtLeast lib.trivial.release "21.03") -> google-api-core != null && google_api_core == null;
buildPythonPackage rec {
  pname = "cirq";
  version = "0.9.1";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "quantumlib";
    repo = "cirq";
    rev = "v${version}";
    sha256 = "0mygvpq7kzga8l1w2jvwv9a2n3akpss45hrx250gdrnqjp6xrw64";
  };

  postPatch = ''
    substituteInPlace requirements.txt \
      --replace "freezegun~=0.3.15" "freezegun" \
      --replace "matplotlib~=3.0" "matplotlib" \
      --replace "networkx~=2.4" "networkx" \
      --replace "numpy~=1.16" "numpy" \
      --replace "protobuf~=3.12.0" "protobuf"

    # Fix serialize_sympy_constants test by allowing small errors in pi
    substituteInPlace cirq/google/arg_func_langs_test.py \
      --replace "'float_value': float(str(np.float32(sympy.pi)))" "'float_value': pytest.approx(float(str(np.float32(sympy.pi))))"
  '';

  propagatedBuildInputs = [
    freezegun
    # google-api-core == google_api_core, just renamed on nixpkgs >= 20.03
    google_api_core
    google-api-core
    numpy
    matplotlib
    networkx
    pandas
    protobuf
    requests
    scipy
    sortedcontainers
    sympy
    typing-extensions
  ];

  doCheck = true;
  # pythonImportsCheck = [ "cirq" "cirq.Circuit" ];  # cirq's importlib hook doesn't work here
  dontUseSetuptoolsCheck = true;
  checkInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-benchmark
    ply
    pydot
    pyyaml
    pygraphviz
  ];

  pytestFlagsArray = [
    "--ignore=dev_tools"  # Only needed when developing new code, which is out-of-scope
    "--ignore=cirq/contrib/"  # requires external (unpackaged) libraries, so untested.
    "-rfE"
    # "--durations=25"
    "--benchmark-disable"
  ];
  # TODO: remove disables before aarch64 on NixOS 20.09+, working protobuf version.
  disabledTests = [
    "test_convert_to_ion_gates" # seems to fail due to rounding error on CI ONLY, 0.75 != 0.750...2

    # Newly disabled tests on cirq 0.8. Think these fail due to old protobuf
    "engine_job_test"
    "test_health"
    "test_run_delegation"
  ] ++ lib.optionals stdenv.isAarch64 [
    # Seem to fail due to math issues on aarch64?
    "expectation_from_wavefunction"
    "test_single_qubit_op_to_framed_phase_form_output_on_example_case"
  ] ++ [
    # slow tests, for quicker building
    "test_anneal_search_method_calls"
    "test_density_matrix_from_state_tomography_is_correct"
    "test_example_runs_qubit_characterizations"
    "test_example_runs_hello_line_perf"
    "test_example_runs_bc_mean_field_perf"
    "test_main_loop"
    "test_clifford_circuit_2"
    "test_decompose_specific_matrices"
    "test_two_qubit_randomized_benchmarking"
    "test_kak_decomposition_perf"
    "test_example_runs_simon"
    "test_decompose_random_unitary"
    "test_decompose_size_special_unitary"
    "test_api_retry_5xx_errors"
    "test_xeb_fidelity"
    "test_example_runs_phase_estimator_perf"
    "test_cross_entropy_benchmarking"
  ];

  meta = with lib; {
    description = "A framework for creating, editing, and invoking Noisy Intermediate Scale Quantum (NISQ) circuits.";
    homepage = "https://github.com/quantumlib/cirq";
    changelog = "https://github.com/quantumlib/Cirq/releases/tag/v${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
