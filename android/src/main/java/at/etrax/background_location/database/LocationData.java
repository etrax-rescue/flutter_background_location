package at.etrax.background_location.database;

import androidx.annotation.NonNull;
import androidx.room.ColumnInfo;
import androidx.room.Entity;
import androidx.room.PrimaryKey;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

@Entity(tableName = "location_data")
public class LocationData {
    @Expose(serialize = false)
    @PrimaryKey(autoGenerate = true)
    public int id;

    @NonNull
    @Expose
    @SerializedName("time")
    @ColumnInfo(name = "time")
    public long time;

    @NonNull
    @Expose
    @SerializedName("latitude")
    @ColumnInfo(name = "latitude")
    public double latitude;

    @NonNull
    @Expose
    @SerializedName("longitude")
    @ColumnInfo(name = "longitude")
    public double longitude;

    @NonNull
    @Expose
    @SerializedName("accuracy")
    @ColumnInfo(name = "accuracy")
    public float accuracy;

    @Expose
    @SerializedName("altitude")
    @ColumnInfo(name = "altitude")
    public double altitude;

    @Expose
    @SerializedName("speed")
    @ColumnInfo(name = "speed")
    public float speed = -1.0f;

    @Expose
    @SerializedName("speedAccuracy")
    @ColumnInfo(name = "speedAccuracy")
    public float speedAccuracy = -1.0f;

    @Expose
    @SerializedName("heading")
    @ColumnInfo(name = "heading")
    public float heading = -1.0f;

    @Expose(serialize = false)
    @ColumnInfo(name = "label")
    public String label = "";

    @Expose(serialize = false)
    @ColumnInfo(name = "uploaded")
    public boolean uploaded = false;
    
}
