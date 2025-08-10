# Foundry NFT

## 链上 NFT

数据均存储在链下，比如 IPFS

在 IPFS 上传图片，然后创建一个 NFT Metadata 的 JSON 文件也放到 IPFS 上

```json
{
  "name": "Lulu",
  "description": "Lulu NFT",
  "image": "https://bafybeifqt7e74r2pldna3xdxuonttaht3pu2vutled2rtrmbbe5vtuwypm.ipfs.dweb.link?filename=0.png",
  "attributes": [
    {
      "trait_type": "cuteness",
      "value": 100
    }
  ]
}
```

NFT 的 TokenURI 需要返回这个 JSON 的 URI，用 `ipfs://` 拼上文件的哈希

```
ipfs://QmVwRBznXtw3noqXoCz7pko2itpWhd5mAptAmf4EZbu8eL
```

## 链下 NFT

### 创建图片 URI

将 SVG 通过 Base64 编码，并创建 DataURI，将图片数据直接放到 URI 中

```
data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9 ... 
```

### 创建 Token URI

按照 NFT Metadata 的格式，创建 JSON 文件，`image` 字段放图片的 DataURI

```json
{
  "name": "Weather",
  "description": "Weather NFT",
  "image": "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9 ... ",
  "attributes": [
    {
      "trait_type": "weather",
      "value": 100
    }
  ]
}
```

将 JSON 文件使用 Base64 编码，并创建 DataURI，直接提供给 NFT 合约使用

```
data:application/json;base64,ew0KICAibmFtZSI6ICJXZWF0aGVyIiwNCiAgImRlc2NyaXB0aW9uIjogIldlYXRoZXIgTkZUIiwN ...
```

