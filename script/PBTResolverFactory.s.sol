import "forge-std/Script.sol";
import "../src/PBTResolverFactory.sol";

contract PBTResolverFactoryScript is Script {
    function run() public {
        address agent = 0x071412e301C2087A4DAA055CF4aFa2683cE1e499;

        vm.startBroadcast(msg.sender);

        PBTResolverFactory resolverFactory = new PBTResolverFactory(agent);

        vm.stopBroadcast();
    }
}
