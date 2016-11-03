{ stdenv, buildFractalideComponent, genName, upkeepers
  , generic_text
  , app_counter
  , generic_tuple_text
  , ...}:

buildFractalideComponent rec {
  name = genName ./.;
  src = ./.;
  contracts = [ generic_text app_counter generic_tuple_text ];
  depsSha256 = "1k0430gm725kzvc8g408dz660g8bighr1c2dqvxksgwan565x8pq";

  meta = with stdenv.lib; {
    description = "Component: draw a conrod text";
    homepage = https://github.com/fractalide/fractalide/tree/master/components/maths/boolean/print;
    license = with licenses; [ mpl20 ];
    maintainers = with upkeepers; [ dmichiels sjmackenzie];
  };
}
