pragma solidity ^0.4.18;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}





contract BRFCrowdSaleSettings is Ownable {

  uint256[] public preIcoStartTimes;
  uint256[] public preIcoEndTimes;
  uint256[] public preIcoRates;
  uint256[] public preIcoCaps;
  uint256[] public icoStartTimes;
  uint256[] public icoEndTimes;
  uint256[] public icoRates;
  uint256[] public icoCaps;

  mapping(address => uint256) public whiteList;

  function BRFCrowdSaleSettings (
    uint256[] _preIcoStartTimes,
    uint256[] _preIcoEndTimes,
    uint256[] _preIcoRates,
    uint256[] _preIcoCaps,
    uint256[] _icoStartTimes,
    uint256[] _icoEndTimes,
    uint256[] _icoRates,
    uint256[] _icoCaps) public
  {
    require((_preIcoCaps[0] > 0) && (_preIcoCaps[1] > 0) && (_preIcoCaps[2] > 0));
    require((_icoCaps[0] > 0) && (_icoCaps[1] > 0) && (_icoCaps[2] > 0));
    require((_preIcoRates[0] > 0) && (_preIcoRates[1] > 0) && (_preIcoRates[2] > 0));
    require((_icoRates[0] > 0) && (_icoRates[1] > 0) && (_icoRates[2] > 0));
    require((_preIcoEndTimes[0] > _preIcoStartTimes[0]) && (_preIcoEndTimes[1] > _preIcoStartTimes[1]) && (_preIcoEndTimes[2] > _preIcoStartTimes[2]));
    require((_icoEndTimes[0] > _icoStartTimes[0]) && (_icoEndTimes[1] > _icoStartTimes[1]) && (_icoEndTimes[2] > _icoStartTimes[2]));
    require((_preIcoStartTimes[1] >= _preIcoEndTimes[0]) && (_preIcoStartTimes[2] >= _preIcoEndTimes[1]));
    require((_icoStartTimes[1] >= _icoEndTimes[0]) && (_icoStartTimes[2] >= _icoEndTimes[1]));

    preIcoStartTimes = _preIcoStartTimes;
    preIcoEndTimes = _preIcoEndTimes;
    preIcoRates = _preIcoRates;
    preIcoCaps = _preIcoCaps;
    icoStartTimes = _icoStartTimes;
    icoEndTimes = _icoEndTimes;
    icoRates = _icoRates;
    icoCaps = _icoCaps;
  }

  function addWhiteLists(address[] wlAddresses, uint256 rate) public onlyOwner {
    for (uint256 index = 0; index < wlAddresses.length; index++) {
      whiteList[wlAddresses[index]] = rate;
    }
  }

  function getTokenRate(address beneficiary) public view returns (uint256) {
    uint stage = getStage(now);
    if ((stage < 3) && (whiteList[beneficiary] > 0)) { // is PreICO and WhiteListed, Use WhiteList Rate
      return whiteList[beneficiary];
    }
    return getRate(stage);
  }

  function getRate(uint stage) internal view returns (uint256) {
    if (stage < 3) {
      return preIcoRates[stage];
    } else {
      return icoRates[(stage - 3)];
    }
  }

  function getStage(uint currTime) internal view returns (uint) {
    if (currTime < preIcoEndTimes[0]) {
      return 0;
    } else if ((currTime > preIcoEndTimes[0]) && (currTime <= preIcoEndTimes[1])) {
      return 1;
    } else if ((currTime > preIcoEndTimes[1]) && (currTime <= preIcoEndTimes[2])) {
      return 2;
    } else if ((currTime > preIcoEndTimes[2]) && (currTime <= icoEndTimes[0])) {
      return 3;
    } else if ((currTime > icoEndTimes[1]) && (currTime <= icoEndTimes[2])) {
      return 4;
    } else {
      return 5;
    }
  }

}