import { useEffect, useRef, useState } from 'react'
import './App.css'
import type { Incoming } from './types/types'
import WorldMap from './components/WorldMap'

function App() {
  const [fires, setFires] = useState<Array<Incoming>>([])

  const ws: React.RefObject<null | WebSocket> = useRef(null);

  useEffect(() => {
    ws.current = new WebSocket("ws://localhost:4000/websocket")
    ws.current.onopen = () => console.log("WS Opened!")
    ws.current.onclose = () => console.log("WS Closed!")

    const {current} = ws;

    return () => {
      current.close();
    };

  }, [])

  useEffect(() => {
    if (!ws?.current) {
      return;
    }

    ws.current.onmessage = e => {
      const message = JSON.parse(e.data);
      setFires(message as Array<Incoming>);
    }
  }, [])

  return (
    <>
      <h1>All Current US Wildfires</h1>
      <div className="card">
        {WorldMap(fires)}
      </div>
    </>
  )
}

export default App
