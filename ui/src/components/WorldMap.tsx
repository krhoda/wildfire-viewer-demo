import { MapContainer, Marker, Polygon, Popup, TileLayer } from 'react-leaflet';
import 'leaflet/dist/leaflet.css'; // Make sure to import Leaflet's CSS
import type { Incoming, Perims } from '../types/types';

const WorldMap = (incoming: Array<Incoming>, perims: Array<Perims>) => {

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
      {incoming?.length && incoming.map((fire) => {
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

      {perims?.length && perims.map((perim, i) => {
        let positions = perim.geometry.coordinates.map((x) => {
            return [x[1], x[0]]
        });
        let name = perim.properties.name;
        let key = `${i}-${name}`;

        return (
            <Polygon key={key} positions={positions}>
                <Popup>
                    {name}
                </Popup>
            </Polygon>
        );
      })}
    </MapContainer>
  );
};

export default WorldMap;