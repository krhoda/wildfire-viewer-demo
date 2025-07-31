import { MapContainer, Marker, Popup, TileLayer } from 'react-leaflet';
import 'leaflet/dist/leaflet.css'; // Make sure to import Leaflet's CSS
import type { Incoming } from '../types/types';

const WorldMap = (incoming: Array<Incoming>) => {
  // Center of the world (roughly)
//   const center = [0, 0]; 
//   const zoom = 2; // Adjust zoom level to see the entire world

  return (
    <MapContainer 
        //@ts-ignore
        center={[47,-120]}
        zoom={3}
        style={{ height: '550px', width: '650px' }}
    >
      <TileLayer
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      />
      {incoming.map((fire) => {
        // TODO: Figure out why I have to flip x/y here.
        let position = [fire.geometry.coordinates[1], fire.geometry.coordinates[0]];
        let name = fire.properties.name;
        let key = `${position[0]}:${position[1]}:${name}}`;
        return (
            <Marker position={position} key={key}>
                <Popup>
                    {name}
                </Popup>
            </Marker>
        );
      })} 
    </MapContainer>
  );
};

export default WorldMap;