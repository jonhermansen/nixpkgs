{ lib
, buildPythonPackage
, fetchFromGitHub
, pythonOlder
, aiodns
, aiohttp
, backports-zoneinfo
}:

buildPythonPackage rec {
  pname = "forecast-solar";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "home-assistant-libs";
    repo = "forecast_solar";
    rev = "refs/tags/${version}";
    hash = "sha256-1xRbTOeBHzLmf0FJwsrg/4+Z2Fs7uwbQwS2Tm41mNRk=";
  };

  PACKAGE_VERSION = version;

  propagatedBuildInputs = [
    aiodns
    aiohttp
  ] ++ lib.optionals (pythonOlder "3.9") [
    backports-zoneinfo
  ];

  # no unit tests implemented
  doCheck = false;

  pythonImportsCheck = [ "forecast_solar" ];

  meta = with lib; {
    description = "Asynchronous Python client for getting forecast solar information";
    homepage = "https://github.com/home-assistant-libs/forecast_solar";
    license = licenses.mit;
    maintainers = with maintainers; [ dotlambda ];
  };
}
