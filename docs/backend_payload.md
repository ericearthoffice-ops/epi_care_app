# Samsung Health Sensor Payload Guide

The mobile client now buffers every reading coming from the Galaxy Watch and
sends them to the backend in 10-second batches. Each POST request to
`$_baseUrl$_healthDataEndpoint` (configure the base URL in
`lib/services/seizure_prediction_service.dart`) has the following structure:

```json
{
  "metadata": {
    "batchSize": 3,
    "trackers": ["heart_rate", "bia", "ecg"],
    "window": {
      "start": "2025-11-06T02:15:30.110Z",
      "end": "2025-11-06T02:15:35.402Z"
    },
    "sentAt": "2025-11-06T02:15:36.012Z"
  },
  "data": [
    {
      "type": "heart_rate",
      "timestamp": "2025-11-06T02:15:30.110Z",
      "value": 72,
      "unit": "bpm",
      "status": 0,
      "metrics": {"value": 72},
      "raw": {...}
    },
    {
      "type": "bia",
      "timestamp": "2025-11-06T02:15:31.870Z",
      "metrics": {
        "bodyFat": 18.4,
        "skeletalMuscle": 24.7,
        "bodyWater": 33.1
      },
      "units": {
        "bodyFat": "%",
        "skeletalMuscle": "kg",
        "bodyWater": "kg"
      },
      "status": 0,
      "raw": {...}
    },
    {
      "type": "ecg",
      "timestamp": "2025-11-06T02:15:32.920Z",
      "metrics": {
        "hr": 71,
        "rRInterval": 0.86,
        "signalQuality": "good"
      },
      "status": 1,
      "raw": {...}
    }
  ]
}
```

### Field notes

- `metadata.trackers` lists every sensor type included in the batch. Expect the
  following tracker identifiers: `heart_rate`, `spo2`, `bia`, `mf_bia`,
  `bio_active_sensor`, `ecg`, `eda`, `ibi`, `ppg`, `sleep_stage`,
  `skin_temperature`.
- Each `data` item always contains `type`, `timestamp`, `metrics`, and `raw`.
  Scalar sensors also expose the helper fields `value`, `unit`, and `heartRate`
  when available.
- `raw` mirrors the payload received from the native Samsung Health Sensor SDK.
  It is safe to treat it as opaque diagnostic data if you only need the
  normalized fields.
- The client retries failed posts by re-queuing the batch. Make sure to return
  HTTP 200/201 when ingestion succeeds.

### Suggested backend handling flow

1. Validate mandatory fields (`metadata`, `data[*].type`, `data[*].timestamp`).
2. Fan out the metrics to your storage or analytics pipeline. `metrics` is a
   free-form map, so prefer schema-on-read (e.g., JSON/Parquet column storage).
3. Store the batch metadata to reconstruct ingestion latency or detect missed
   uploads.
4. Optionally respond with a prediction payload such as:
   ```json
   {
     "predictionProbability": 78.4,
     "predictionWindowMinutes": 30,
     "modelVersion": "2025.11.0"
   }
   ```
   When `predictionProbability` is present, the mobile client raises an
   in-app notification and opens the seizure alert screen.

Update this document as you refine the backend contract.
