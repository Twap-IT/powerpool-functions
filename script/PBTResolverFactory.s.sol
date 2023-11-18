import "forge-std/Script.sol";
import "../src/PBTResolverFactory.sol";

contract PBTResolverFactoryScript {
  function run() {
    address agent = "0x071412e301c2087a4daa055cf4afa2683ce1e499";

    vm.startBroadcast(msg.sender);

    PBTResolverFactory resolverFactory = new PBTResolverFactory(agent);

    vm.stopBroadcast();
  }

}
