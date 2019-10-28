pragma solidity 0.4.24;

import "chainlink/contracts/ChainlinkClient.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title MyContract is an example contract which requests data from
 * the Chainlink network
 * @dev This contract is designed to work on multiple networks, including
 * local test networks
 */
contract MyContract is ChainlinkClient, Ownable {
  uint256 public data;

  //task
  struct Task {
   address ClientId;
   address WorkerId;
   uint Meters;
   uint PricePerMeter;
   uint TaskInex;
   //index in the listOfTasks
   uint ArrayIndex;
   // add private data hash here
   string userData;
   bool initialized;
   bool payed;
   uint payedPrice;
   string taskData;
}

//worker

struct Worker {
       address id;
       uint pricePerMetter;

       // average = new +  (current * (cnt -1)) / cnt
       uint rating;
       uint ratedTasks;

       uint credibility;
       uint dailyMeters;

       uint currentTask;

       uint[] WorkerTasks;

       //credibility comes from theese
       uint completedTasks;
       uint AllTasks;

       bool initialized;
   }

   struct Client {

      address id;

      uint credibility;

      uint currentTask;

      uint[] ClientTasks;

      uint completedTasks;
      uint AllTasks;

      bool initialized;


  }

  //so they stay in the same place and in the worker and client accound we just pu the indexes
// the we make an array of finished and unfinished based on this indexes and everything else, nice
uint TaskIndexCounter;
mapping (uint => Task)  Tasks;

// Unpaid tasks go here, then when the contracts analyzes them, pays the workers, it refreshes;
  uint[] PayDay;

  //Workers accounts
  mapping (address => Worker) Workers;
  address[] public listOfWorkers;

//Clients accounts
  mapping (address => Client) Clients;
  address[] public listOfClients;

  //workers orders  TODO
  mapping (uint => string) WorkerOrders;
  address[] public listOfWorkerOrders;

  /**
   * @notice Deploy the contract with a specified address for the LINK
   * and Oracle contract addresses
   * @dev Sets the storage for the specified addresses
   * @param _link The address of the LINK token contract
   */
  constructor(address _link) public {
    if (_link == address(0)) {
      setPublicChainlinkToken();
    } else {
      setChainlinkToken(_link);
    }
  }


//register worker
//register Client   //?at first requested task

  // first layer
  function requestTask(uint meters,uint pricePerMeter, string usrData) public view returns(uint){
    // uint taskIndex = listOfTasks.push(msg.sender);
    TaskIndexCounter++;
    Tasks[TaskIndexCounter] = Task(msg.sender, address(0), meters, pricePerMeter,TaskIndexCounter , 0 , usrData, true ,false,0,'0');

    setTaskToClient(TaskIndexCounter,msg.sender);
    findWorker(TaskIndexCounter);
    return TaskIndexCounter;
//creates task
  }

  function getTaskUsrData(uint taskIndex)public view returns(string){
    return Tasks[taskIndex].userData;
  }


  //workerRating  0 -> 5 less than 5!
  function finishTaskCtoW(uint tid, uint workerRating)public view returns(bool){
      if(!taskExists(tid)){
        return false;
      }
      // commented out for testing purpesses
      // if(Tasks[tid].ClientId != msg.sender){
      //   retrun 0;
      // }
      // commented out for testing purpesses
      // if(workerRating > 5){
      //   retrun 0;
      // }

      updateWorkerRating(Tasks[tid].WorkerId ,workerRating );



  }

  function updateWorkerRating(address workerAddress, uint newRating){
    if(Workers[workerAddress].rating == 0){
      Workers[workerAddress].rating = newRating;
      Workers[workerAddress].ratedTasks++;
    }else {
       // average = new +  (current * (cnt -1)) / cnt

      Workers[workerAddress].ratedTasks++;
      uint rcnt = Workers[workerAddress].ratedTasks;
      uint rt = Workers[workerAddress].rating;
      uint avr = rt * (rcnt - 1);
      Workers[workerAddress].rating = ((newRating + avr) / rcnt );
    }

  }

  function updateClient(){

  }


  function setTaskToClient(uint tid, address cid) {
    registerClient(cid);
    Clients[cid].currentTask = tid;
    Clients[cid].AllTasks++;
    Clients[cid].ClientTasks.push(tid);
  }

  function setTaskToWorker(uint tid, address wid){
    registerWorker(wid); // this is not needed
    Workers[wid].currentTask = tid;
    Workers[wid].AllTasks++;
    Workers[wid].WorkerTasks.push(tid);
  }


  function registerClient(address cid) public view returns(int){
    if(!clientExists(cid)){
      Clients[cid].id = cid;
      Clients[cid].initialized = true;
    }
  }

  function clientExists(address cid)  public view returns(bool){
    if(!Clients[cid].initialized){
      return false;
    }else if (Clients[cid].initialized){
      return true;
    }
    return false;
//creates task
  }

  function workerExists(address cid)  public view returns(bool){
    if(!Workers[cid].initialized){
      return false;
    }else if (Workers[cid].initialized){
      return true;
    }
    return false;
//creates task
  }

  function taskExists(uint tid)  public view returns(bool){
    if(!Tasks[tid].initialized){
      return false;
    }else if (Tasks[tid].initialized){
      return true;
    }
    return false;
//creates task
  }


  function registerWorker(address cid){
    if(!workerExists(cid)){
      Workers[cid].id = cid;
      Workers[cid].initialized = true;
    }

  }

  function getWorker(address cid) public view returns(address){
    if(workerExists(cid)){
        return Workers[cid].id;
    }else {
      return 0x8094d726775e32fbDe869989F5270528eBc1f013;
    }
  }




  function findWorker(uint taskIndex) private{

    //Tasks[taskIndex].WorkerId = 0x8094d726775e32fbDe869989F5270528eBc1f0a4;
  //  requestWorker(_oracle_WorkerFinder,_jobId_WorkerFinder, _payment_WorkerFinder, t);
// i might not need this function
// sends task to ai
// ai finds Worker
// then setWorker updates the task
   }

   function payTask(uint tid) payable returns(uint ){
     uint price;
    if(msg.value==0)
    {
        return 0;
    }

    if(Tasks[tid].initialized) {
        price = Tasks[tid].Meters * Tasks[tid].PricePerMeter;
        if(price < msg.value){
          Tasks[tid].payed = true;
          Tasks[tid].payedPrice = msg.value;
        }
    }


    //if(msg.value > price){

    //  return 1;
  //  }

    //and return his money;
    return 1;
}

function checkTaskStatus(uint tid) public view returns(bool){
  return Tasks[tid].payed;
}

function getTaskAddress(uint id) public view returns(address a){
		return ( Tasks[id].WorkerId) ;
	}

 //  function checkCA(address id) public view returns(address a){
 //   if(!Clients[id].initialized){
 //     return address(0);
 //   }else if(Clients[id].initialized){
 //     return 0x8094d726775e32fbDe869989F5270528eBc1f042;
 //   }
 //   return 0x8094d726775e32fbDe869989F5270528eBc1f013;
 // }



  /**
   * @notice Returns the address of the LINK token
   * @dev This is the public implementation for chainlinkTokenAddress, which is
   * an internal method of the ChainlinkClient contract
   */
  function getChainlinkToken() public view returns (address) {
    return chainlinkTokenAddress();
  }

  /**
   * @notice Creates a request to the specified Oracle contract address
   * @dev This function ignores the stored Oracle contract address and
   * will instead send the request to the address specified
   * @param _oracle The Oracle contract address to send the request to
   * @param _jobId The bytes32 JobID to be executed
   * @param _url The URL to fetch data from
   * @param _path The dot-delimited path to parse of the response
   * @param _times The number to multiply the result by
   */
  function createRequestTo(
    address _oracle,
    bytes32 _jobId,
    uint256 _payment,
    string _url,
    string _path,
    int256 _times
  )
    public
    onlyOwner
    returns (bytes32 requestId)
  {
    Chainlink.Request memory req = buildChainlinkRequest(_jobId, this, this.fulfill.selector);
    req.add("url", _url);
    req.add("path", _path);
    req.addInt("times", _times);
    requestId = sendChainlinkRequestTo(_oracle, req, _payment);
  }

  /**
   * @notice The fulfill method from requests created by this contract
   * @dev The recordChainlinkFulfillment protects this function from being called
   * by anyone other than the oracle address that the request was sent to
   * @param _requestId The ID that was generated for the request
   * @param _data The answer provided by the oracle
   */
  function fulfill(bytes32 _requestId, uint256 _data)
    public
    recordChainlinkFulfillment(_requestId)
  {
    data = _data;
  }

  /**
   * @notice Allows the owner to withdraw any LINK balance on the contract
   */
  function withdrawLink() public onlyOwner {
    LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
    require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
  }

  /**
   * @notice Call this method if no response is received within 5 minutes
   * @param _requestId The ID that was generated for the request to cancel
   * @param _payment The payment specified for the request to cancel
   * @param _callbackFunctionId The bytes4 callback function ID specified for
   * the request to cancel
   * @param _expiration The expiration generated for the request to cancel
   */
  function cancelRequest(
    bytes32 _requestId,
    uint256 _payment,
    bytes4 _callbackFunctionId,
    uint256 _expiration
  )
    public
    onlyOwner
  {
    cancelChainlinkRequest(_requestId, _payment, _callbackFunctionId, _expiration);
  }
}
