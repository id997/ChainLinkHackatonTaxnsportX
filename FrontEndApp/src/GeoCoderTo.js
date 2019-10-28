import React, { Component } from 'react';
import Geocode from "react-geocode";


class GeoCoderTo extends React.Component {

  constructor(props) {
      super(props);
      this.state = {title: 'hi'};
      Geocode.setApiKey("AIzaSyDxUkBiaD-AEumX2D53QkOXTEHgFWcxO8s");

      // set response language. Defaults to english.
      Geocode.setLanguage("en");

      // set response region. Its optional.
      // A Geocoding request with region=es (Spain) will return the Spanish city.
      Geocode.setRegion("es");

      // Enable or disable logs. Its optional.
      Geocode.enableDebug();

      // Get address from latidude & longitude.
      // Geocode.fromLatLng("48.8583701", "2.2922926").then(
      //   response => {
      //     const address = response.results[0].formatted_address;
      //     console.log(address);
      //   },
      //   error => {
      //     console.error(error);
      //   }
      // );

    }
  // set Google Maps Geocoding API for purposes of quota management. Its optional but recommended.



  handleChange(event) {
    this.setState({title: event.target.value})

    // Get latidude & longitude from address.
    // Geocode.fromAddress(this.state.title).then(
    //   response => {
    //     const { lat, lng } = response.results[0].geometry.location;
    //     console.log(lat, lng);
    //   },
    //   error => {
    //     console.error(error);
    //   }
    // );

  }

  activateLasers() {


    // Get latidude & longitude from address.
    Geocode.fromAddress(this.state.title).then(
      response => {
        const { lat, lng } = response.results[0].geometry.location;
        this.props.parentCallback({ lat, lng });
        console.log(lat, lng);
      },
      error => {
        console.error(error);
      }
    );

  }

  render() {

  //   <button onclick="activateLasers()">
  // Activate Lasers
  // </button>
  return( <div> <input type='text' name='title' value={this.state.title}
    onChange={this.handleChange.bind(this)}/>
    <button onClick={this.activateLasers.bind(this)}>
  To Location
</button>
  </div> );
  }
}

export default GeoCoderTo;
