/**
 * DownloadHandlerFile.cs
 * Author: Luke Holland (http://lukeholland.me/)
 */

using System.IO;
using UnityEngine;
using UnityEngine.Networking;

public class DownloadHandlerFile2 : DownloadHandlerScript
{

    public int contentLength { get { return _received > _contentLength ? _received : _contentLength; } }

    private int _contentLength;
    private int _received;
    private FileStream _stream;

    public DownloadHandlerFile2(string localFilePath, int bufferSize = 4096, FileShare fileShare = FileShare.ReadWrite) : base(new byte[bufferSize])
    {
        string directory = Path.GetDirectoryName(localFilePath);
        if (!Directory.Exists(directory)) Directory.CreateDirectory(directory);

        _contentLength = -1;
        _received = 0;
        _stream = new FileStream(localFilePath, FileMode.OpenOrCreate, FileAccess.Write, fileShare, bufferSize);
    }

    protected override float GetProgress()
    {
        return contentLength <= 0 ? 0 : Mathf.Clamp01(_received / (float)contentLength);
    }

    protected override void ReceiveContentLength(int contentLength)
    {
        _contentLength = contentLength;
    }

    protected override bool ReceiveData(byte[] data, int dataLength)
    {
        if (data == null || data.Length == 0) return false;

        _received += dataLength;
        _stream.Write(data, 0, dataLength);

        return true;
    }

    protected override void CompleteContent()
    {
        CloseStream();
    }

    public new void Dispose()
    {
        CloseStream();
        base.Dispose();
    }

    private void CloseStream()
    {
        if (_stream != null)
        {
            _stream.Dispose();
            _stream = null;
        }
    }

}