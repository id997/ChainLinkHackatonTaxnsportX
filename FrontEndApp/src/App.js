import React, {
  Component
} from 'react';
import logo from './logo.svg';
import './App.css';
import MycontractAbi from './contractAbi.json';

// import web3 from 'web3';
import web3 from './web3';

import ipfs from './ipfs';
import storeMyValue from './MyContract';

import GeoCoderFrom from './GeoCoderFrom'
import GeoCoderTo from './GeoCoderTo'


class App extends Component {

  constructor(props) {
      super(props);

    }

  state = {
    ipfsHash: null,
    buffer: '',
    transactionHash: '',
    gasUsed: '',
    txReceipt: '',
    fromLocation: '',
    toLocation:'',
    finalTask: '',
    ethAddress: '',
  };

  callbackFunctionLocationFrom = (latLng) => {
      console.log("From" + latLng.lat + " " + latLng.lng );
      this.setState({fromLocation: latLng.lat})
};

callbackFunctionLocationTo = (latLng) => {
    console.log("To" +  latLng.lat + " " + latLng.lng);
    this.setState({toLocation: latLng})
    console.log("state" + this.state.toLocation.lat);
};

setFinalLocationAsBuffer = async () => {
  let finalTask = {
    FromLoc: this.state.fromLocation,
    ToLoc: this.state.toLocation
  }
  console.log(this.state.fromLoc);
   finalTask = JSON.stringify(finalTask);
   console.log(finalTask);
   finalTask = await Buffer.from(finalTask);
   console.log(finalTask);
  //set this buffer -using es6 syntax
  this.setState({
    finalTask
  });
};

requestATask = async () => {

  console.log("web3 value is ", web3.eth.getAccounts());

  const accounts = await web3.eth.getAccounts();

  console.log('Sending from Metamask account: ', accounts[0]);

  const ethAddress = await storeMyValue.options.address;

  this.setState({
    ethAddress
  });

  await ipfs.add(this.state.finalTask, (err, ipfsHash) => {
    console.log(err, ipfsHash);
    this.setState({
      ipfsHash: ipfsHash[0].hash
    });

    storeMyValue.methods.requestTask(100, 100, this.state.ipfsHash).send({
      from: accounts[0]
    }, (error, transactionHash) => {
      console.log("transaction hash is ", transactionHash);
      this.setState({
        transactionHash
      });
    });
  })

}

  captureFile = (event) => {
    event.stopPropagation()
    event.preventDefault()
    const file = event.target.files[0]
    let reader = new window.FileReader()
    reader.readAsArrayBuffer(file)
    reader.onloadend = () => this.convertToBuffer(reader)
  };

  convertToBuffer = async (reader) => {
    //file is converted to a buffer for upload to IPFS

    const buffer = await Buffer.from(reader.result);
    //set this buffer -using es6 syntax
    this.setState({
      buffer
    });
  };

  onSubmit = async (event) => {
    event.preventDefault();
    console.log("web3 value is ", web3.eth.getAccounts());
    const accounts = await web3.eth.getAccounts();
    console.log('Sending from Metamask account: ', accounts[0]);
    const ethAddress = await storeMyValue.options.address;
    this.setState({
      ethAddress
    });

    await ipfs.add(this.state.buffer, (err, ipfsHash) => {
      console.log(err, ipfsHash);
      this.setState({
        ipfsHash: ipfsHash[0].hash
      });
      storeMyValue.methods.requestTask(100, 100, this.state.ipfsHash).send({
        from: accounts[0]
      }, (error, transactionHash) => {
        console.log("transaction hash is ", transactionHash);
        this.setState({
          transactionHash
        });
      });
    })
  };
  render() {
    return ( <
      div className = "App" >
      <header className = "App-header" >
      <h1 > IPFS Dapp < /h1>
      <GeoCoderTo parentCallback = {this.callbackFunctionLocationTo}/>
      <GeoCoderFrom parentCallback = {this.callbackFunctionLocationFrom}/>
      <button  onClick={this.setFinalLocationAsBuffer} > Buffer < /button>
      <button  onClick={this.requestATask} > requestTask < /button>
       <
      /header> <  hr / >
      <
      h3 > Choose file to send to IPFS < /h3> <
      form onSubmit = {
        this.onSubmit
      } >
      <
      input type = "file"
      onChange = {
        this.captureFile
      }
      /> <
      button type = "submit" > Send it < /button> <
      /form> <
      hr / >
      <
      table >
      <
      thead >
      <
      tr >
      <
      th > Sl No < /th> <
      th > Values < /th> <
      /tr> <
      /thead> <
      tbody >
      <
      tr >
      <
      td > IPFS Hash# stored on Eth Contract < /td> <
      td > {
        this.state.ipfsHash
      } < /td> <
      /tr> <
      tr >
      <
      td > Ethereum Contract Address < /td> <
      td > {
        this.state.ethAddress
      } < /td> <
      /tr> <
      tr >
      <
      td > Tx Hash# < /td> <
      td > {
        this.state.transactionHash
      } < /td> <
      /tr> <
      /tbody> <
      /table>

       <
      /div>);
    }
  }
  export default App;
