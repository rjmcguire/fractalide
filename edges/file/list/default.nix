{ edge, edges }:

edge {
  src = ./.;
  edges =  with edges; [];
  schema = with edges; ''
    @0xc5286a3290514068;

    using PrimText = import "${prim_text}/src/edge.capnp";

    struct FileList {
        list @0 :List(PrimText);
    }
  '';
}
